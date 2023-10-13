
#include "image_parser_v2.h"
#include "webp_compat.h"

void _advance_padding(Ref<FileAccess> f, uint32_t p_len) {
	uint32_t extra = 4 - (p_len % 4);
	if (extra < 4) {
		for (uint32_t i = 0; i < extra; i++) {
			f->get_8(); // pad to 32
		}
	}
}

Ref<Image> ImageParserV2::convert_indexed_image(const Vector<uint8_t> &p_imgdata, int p_width, int p_height, int p_mipmaps, V2Image::Format p_format, Error *r_error) {
	Vector<uint8_t> r_imgdata;
	Image::Format r_format;
	int datalen = p_imgdata.size();
	if (r_error) {
		*r_error = OK;
	}
	if ((p_format != 5 && p_format != 6 && p_format != 1)) {
		if (r_error) {
			*r_error = ERR_INVALID_PARAMETER;
		}
		return Ref<Image>();
	}
	if (p_format == V2Image::IMAGE_FORMAT_INTENSITY) {
		r_format = Image::FORMAT_RGBA8;
		r_imgdata.resize(datalen * 4);
		for (int i = 0; i < datalen; i++) {
			r_imgdata.write[i * 4] = 255;
			r_imgdata.write[i * 4 + 1] = 255;
			r_imgdata.write[i * 4 + 2] = 255;
			r_imgdata.write[i * 4 + 3] = p_imgdata[i];
		}
	} else {
		int pal_width;
		if (p_format == V2Image::IMAGE_FORMAT_INDEXED) {
			r_format = Image::FORMAT_RGB8;
			pal_width = 3;
		} else { // V2Image::IMAGE_FORMAT_INDEXED_ALPHA
			r_format = Image::FORMAT_RGBA8;
			pal_width = 4;
		}

		Vector<Vector<uint8_t>> palette;

		// palette data starts at end of pixel data, is equal to 256 * pal_width
		for (int dataidx = p_width * p_height; dataidx < p_imgdata.size(); dataidx += pal_width) {
			palette.push_back(p_imgdata.slice(dataidx, dataidx + pal_width));
		}
		// pixel data is index into palette
		for (int i = 0; i < p_width * p_height; i++) {
			r_imgdata.append_array(palette[p_imgdata[i]]);
		}
	}
	Ref<Image> img = Image::create_from_data(p_width, p_height, p_mipmaps > 0, r_format, r_imgdata);
	if (img.is_null() && r_error) {
		*r_error = ERR_PARSE_ERROR;
	}
	return img;
}

String ImageParserV2::image_v2_to_string(const Variant &r_v, bool is_pcfg) {
	Ref<Image> img = r_v;
	String imgstr = is_pcfg ? "img(" : "Image(";
	if (img.is_null() || img->is_empty()) {
		return String(imgstr + ")");
	}

	imgstr += " ";
	imgstr += itos(img->get_width());
	imgstr += ", " + itos(img->get_height());
	String subimgstr = ", " + itos(img->get_mipmap_count()) + ", ";
	Image::Format fmt = img->get_format();
	String fmt_id = is_pcfg ? ImageEnumCompat::get_v2_format_identifier_pcfg(ImageEnumCompat::convert_image_format_enum_v4_to_v2(fmt), img->get_data().size()) : ImageEnumCompat::get_v2_format_identifier(ImageEnumCompat::convert_image_format_enum_v4_to_v2(fmt));

	imgstr += subimgstr + fmt_id;

	String s;

	Vector<uint8_t> data = img->get_data();
	int len = data.size();
	for (int i = 0; i < len; i++) {
		if (i > 0)
			s += ", ";
		s += itos(data[i]);
	}

	imgstr += ", " + s + " )";
	return imgstr;
}

Error ImageParserV2::write_image_v2_to_bin(Ref<FileAccess> f, const Variant &r_v, bool compress_lossless) {
	Ref<Image> val = r_v;
	if (val.is_null() || val->is_empty()) {
		f->store_32(V2Image::IMAGE_ENCODING_EMPTY);
		return OK;
	}

	int encoding = V2Image::IMAGE_ENCODING_RAW;
	//float quality = 0.7;

	if (val->get_format() <= Image::FORMAT_RGB565) {
		// can only compress uncompressed stuff
		if (compress_lossless && Image::png_packer) {
			encoding = V2Image::IMAGE_ENCODING_LOSSLESS;
		}
		// We do not want to resave the image as lossy because of:
		// 1) We lose fidelity from the original asset if we do
		// 2) V4 encoding is incompatible with V2 and V3
		else if (compress_lossless && Image::png_packer) {
			encoding = V2Image::IMAGE_ENCODING_LOSSLESS;
		}
	}

	f->store_32(encoding); // raw encoding

	if (encoding == V2Image::IMAGE_ENCODING_RAW) {
		f->store_32(val->get_width());
		f->store_32(val->get_height());
		int mipmaps = val->get_mipmap_count();
		V2Image::Format fmt = ImageEnumCompat::convert_image_format_enum_v4_to_v2(val->get_format());
		ERR_FAIL_COND_V_MSG(fmt == V2Image::IMAGE_FORMAT_V2_MAX, ERR_FILE_CORRUPT,
				"Can't convert new image to v2 image variant!");
		f->store_32(mipmaps);
		f->store_32(fmt);
		int dlen = val->get_data().size();
		f->store_32(dlen);
		f->store_buffer(val->get_data().ptr(), dlen);
		_advance_padding(f, dlen);
	} else {
		Vector<uint8_t> data;

		if (encoding == V2Image::IMAGE_ENCODING_LOSSLESS) {
			data = Image::png_packer(val);
		}

		int ds = data.size();
		f->store_32(ds);
		if (ds > 0) {
			f->store_buffer(data.ptr(), ds);
			_advance_padding(f, ds);
		}
	}
	return OK;
}

Error ImageParserV2::decode_image_v2(Ref<FileAccess> f, Variant &r_v, bool convert_indexed) {
	uint32_t encoding = f->get_32();
	Ref<Image> img;

	if (encoding == V2Image::IMAGE_ENCODING_EMPTY) {
		img.instantiate();
		r_v = img;
		return OK;
	} else if (encoding == V2Image::IMAGE_ENCODING_RAW) {
		uint32_t width = f->get_32();
		uint32_t height = f->get_32();
		uint32_t mipmaps = f->get_32();
		uint32_t old_format = f->get_32();
		Image::Format fmt = ImageEnumCompat::convert_image_format_enum_v2_to_v4((V2Image::Format)old_format);

		uint32_t datalen = f->get_32();

		Vector<uint8_t> imgdata;
		imgdata.resize(datalen);
		uint8_t *w = imgdata.ptrw();
		f->get_buffer(w, datalen);
		_advance_padding(f, datalen);
		// This is for if we're saving the image as a png.
		if (convert_indexed && (old_format == 5 || old_format == 6 || old_format == 1)) {
			Error err;
			img = ImageParserV2::convert_indexed_image(imgdata, width, height, mipmaps, (V2Image::Format)old_format, &err);
			ERR_FAIL_COND_V_MSG(err, err,
					"Can't convert deprecated image format " + ImageEnumCompat::get_v2_format_name((V2Image::Format)old_format) + " to new image formats!");
		} else {
			// We wait until we've skipped all the data to do this
			ERR_FAIL_COND_V_MSG(
					fmt == Image::FORMAT_MAX && (old_format > 0 && old_format < V2Image::IMAGE_FORMAT_V2_MAX),
					ERR_UNAVAILABLE,
					"Converting deprecated image format " + ImageEnumCompat::get_v2_format_name((V2Image::Format)old_format) + " not implemented.");
			ERR_FAIL_COND_V_MSG(
					fmt == Image::FORMAT_MAX,
					ERR_FILE_CORRUPT,
					"Invalid format");

			img = Image::create_from_data(width, height, mipmaps > 0, fmt, imgdata);
		}
	} else {
		// compressed
		Vector<uint8_t> data;
		data.resize(f->get_32());
		uint8_t *w = data.ptrw();
		f->get_buffer(w, data.size());
		// Godot 2.0 sometimes exported empty images as "IMAGE_ENCODING_LOSSY" rather than "IMAGE_ENCODING_EMPTY", so we need to check for that.
		if (data.size() == 0) {
			img.instantiate();
			r_v = img;
			return OK;
		}
		if (encoding == V2Image::IMAGE_ENCODING_LOSSY) {
			img = WebPCompat::webp_unpack_v2v3(data);
		} else if (encoding == V2Image::IMAGE_ENCODING_LOSSLESS && Image::png_unpacker) {
			img = img->png_unpacker(data);
		}
		_advance_padding(f, data.size());
	}
	r_v = img;
	return OK;
}

#define ERR_PARSE_V2IMAGE_FAIL(c_type, error_string) \
	if (token.type != c_type) {                      \
		r_err_str = error_string;                    \
		return ERR_PARSE_ERROR;                      \
	}

#define EXPECT_COMMA()                                          \
	VariantParser::get_token(p_stream, token, line, r_err_str); \
	ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_COMMA, "Expected comma in Image variant")

Error ImageParserV2::parse_image_construct_v2(VariantParser::Stream *p_stream, Variant &r_v, bool convert_indexed, int &line, String &p_err_str) {
	String r_err_str;
	VariantParser::Token token;
	uint32_t width;
	uint32_t height;
	uint32_t mipmaps;
	V2Image::Format old_format;
	Image::Format fmt = Image::FORMAT_MAX;
	Vector<uint8_t> data;
	Ref<Image> img;

	// The "Image" identifier has already been parsed, start with parantheses
	VariantParser::get_token(p_stream, token, line, r_err_str);
	ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_PARENTHESIS_OPEN, "Expected '(' in constructor");

	// w, h, mipmap count, format string, data...
	// width
	VariantParser::get_token(p_stream, token, line, r_err_str);
	ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_NUMBER, "Expected width in Image variant");
	width = token.value;
	EXPECT_COMMA();

	// height
	VariantParser::get_token(p_stream, token, line, r_err_str);
	ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_NUMBER, "Expected height in Image variant");
	height = token.value;
	EXPECT_COMMA();

	// mipmaps
	VariantParser::get_token(p_stream, token, line, r_err_str);
	ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_NUMBER, "Expected mipmap count in Image variant");
	mipmaps = token.value;
	EXPECT_COMMA();

	// format string
	VariantParser::get_token(p_stream, token, line, r_err_str);
	ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_STRING, "Expected format string in Image variant");
	old_format = ImageEnumCompat::get_v2_format_from_string(token.value);
	fmt = ImageEnumCompat::convert_image_format_enum_v2_to_v4(old_format);
	bool first = true;
	EXPECT_COMMA();

	// data
	while (true) {
		if (!first) {
			VariantParser::get_token(p_stream, token, line, r_err_str);
			if (token.type == VariantParser::TK_PARENTHESIS_CLOSE) {
				break;
			} else {
				ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_COMMA, "Expected ',' or ')'");
			}
		}
		VariantParser::get_token(p_stream, token, line, r_err_str);
		if (first && token.type == VariantParser::TK_PARENTHESIS_CLOSE) {
			break;
		}
		ERR_PARSE_V2IMAGE_FAIL(VariantParser::TK_NUMBER, "Expected int in image data");

		data.push_back(token.value);
		first = false;
	}

	if (convert_indexed && (old_format == 5 || old_format == 6 || old_format == 1)) {
		Error err;
		img = ImageParserV2::convert_indexed_image(data, width, height, mipmaps, (V2Image::Format)old_format, &err);
		if (img->is_empty()) {
			r_err_str = "Failed to convert deprecated image format " + ImageEnumCompat::get_v2_format_name((V2Image::Format)old_format) + " to new image format!";
			return err;
		}
	} else {
		if (fmt == Image::FORMAT_MAX) {
			r_err_str = "Converting deprecated image format " + ImageEnumCompat::get_v2_format_name((V2Image::Format)old_format) + " not implemented.";
			return ERR_PARSE_ERROR;
		}
		img = Image::create_from_data(width, height, mipmaps > 0, fmt, data);
	}
	if (img->is_empty()) {
		r_err_str = "Failed to create image";
		return ERR_PARSE_ERROR;
	}

	r_v = img;
	return OK;
}