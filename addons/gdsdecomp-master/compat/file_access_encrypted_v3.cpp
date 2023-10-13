/*************************************************************************/
/*  file_access_encrypted_compat.cpp                                            */
/*************************************************************************/
/*                       This file is part of:                           */
/*                           GODOT ENGINE                                */
/*                      https://godotengine.org                          */
/*************************************************************************/
/* Copyright (c) 2007-2022 Juan Linietsky, Ariel Manzur.                 */
/* Copyright (c) 2014-2022 Godot Engine contributors (cf. AUTHORS.md).   */
/*                                                                       */
/* Permission is hereby granted, free of charge, to any person obtaining */
/* a copy of this software and associated documentation files (the       */
/* "Software"), to deal in the Software without restriction, including   */
/* without limitation the rights to use, copy, modify, merge, publish,   */
/* distribute, sublicense, and/or sell copies of the Software, and to    */
/* permit persons to whom the Software is furnished to do so, subject to */
/* the following conditions:                                             */
/*                                                                       */
/* The above copyright notice and this permission notice shall be        */
/* included in all copies or substantial portions of the Software.       */
/*                                                                       */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,       */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF    */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY  */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,  */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE     */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                */
/*************************************************************************/

#include "file_access_encrypted_v3.h"

#include "core/crypto/crypto_core.h"
#include "core/string/print_string.h"
#include "core/variant/variant.h"

#include <stdio.h>

Error FileAccessEncryptedv3::open_and_parse(Ref<FileAccess> p_base, const Vector<uint8_t> &p_key, Mode p_mode, bool p_with_magic) {
	ERR_FAIL_COND_V_MSG(file != nullptr, ERR_ALREADY_IN_USE, "Can't open file while another file from path '" + file->get_path_absolute() + "' is open.");
	ERR_FAIL_COND_V(p_key.size() != 32, ERR_INVALID_PARAMETER);

	pos = 0;
	eofed = false;
	use_magic = p_with_magic;

	if (p_mode == MODE_WRITE_AES256) {
		data.clear();
		writing = true;
		file = p_base;
		key = p_key;

	} else if (p_mode == MODE_READ) {
		writing = false;
		key = p_key;
		uint32_t magic = p_base->get_32();
		ERR_FAIL_COND_V(magic != ENCRYPTED_HEADER_MAGIC, ERR_FILE_UNRECOGNIZED);

		mode = Mode(p_base->get_32());
		ERR_FAIL_INDEX_V(mode, MODE_MAX, ERR_FILE_CORRUPT);
		ERR_FAIL_COND_V(mode == 0, ERR_FILE_CORRUPT);

		unsigned char md5d[16];
		p_base->get_buffer(md5d, 16);
		length = p_base->get_64();
		base = p_base->get_position();
		ERR_FAIL_COND_V(p_base->get_length() < base + length, ERR_FILE_CORRUPT);
		uint64_t ds = length;
		if (ds % 16) {
			ds += 16 - (ds % 16);
		}

		data.resize(ds);

		uint64_t blen = p_base->get_buffer(data.ptrw(), ds);
		ERR_FAIL_COND_V(blen != ds, ERR_FILE_CORRUPT);

		CryptoCore::AESContext ctx;
		ctx.set_decode_key(key.ptrw(), 256);

		for (uint64_t i = 0; i < ds; i += 16) {
			ctx.decrypt_ecb(&data.write[i], &data.write[i]);
		}

		data.resize(length);

		unsigned char hash[16];
		ERR_FAIL_COND_V(CryptoCore::md5(data.ptr(), data.size(), hash) != OK, ERR_BUG);

		ERR_FAIL_COND_V_MSG(String::md5(hash) != String::md5(md5d), ERR_FILE_CORRUPT, "The MD5 sum of the decrypted file does not match the expected value. It could be that the file is corrupt, or that the provided decryption key is invalid.");

		file = p_base;
	}
	return OK;
}

Error FileAccessEncryptedv3::open_and_parse_password(Ref<FileAccess> p_base, const String &p_key, Mode p_mode) {
	String cs = p_key.md5_text();
	ERR_FAIL_COND_V(cs.length() != 32, ERR_INVALID_PARAMETER);
	Vector<uint8_t> key;
	key.resize(32);
	for (int i = 0; i < 32; i++) {
		key.write[i] = cs[i];
	}

	return open_and_parse(p_base, key, p_mode);
}

Error FileAccessEncryptedv3::open_internal(const String &p_path, int p_mode_flags) {
	return OK;
}

void FileAccessEncryptedv3::_close() {
	if (file.is_null()) {
		return;
	}

	if (writing) {
		Vector<uint8_t> compressed;
		uint64_t len = data.size();
		if (len % 16) {
			len += 16 - (len % 16);
		}

		unsigned char hash[16];
		ERR_FAIL_COND(CryptoCore::md5(data.ptr(), data.size(), hash) != OK); // Bug?

		compressed.resize(len);
		memset(compressed.ptrw(), 0, len);
		for (int i = 0; i < data.size(); i++) {
			compressed.write[i] = data[i];
		}

		CryptoCore::AESContext ctx;
		ctx.set_encode_key(key.ptrw(), 256);

		for (uint64_t i = 0; i < len; i += 16) {
			ctx.encrypt_ecb(&compressed.write[i], &compressed.write[i]);
		}

		file->store_32(ENCRYPTED_HEADER_MAGIC);
		file->store_32(mode);

		file->store_buffer(hash, 16);
		file->store_64(data.size());

		file->store_buffer(compressed.ptr(), compressed.size());
		data.clear();
	}

	file.unref();
}

bool FileAccessEncryptedv3::is_open() const {
	return file != nullptr;
}

String FileAccessEncryptedv3::get_path() const {
	if (file.is_valid()) {
		return file->get_path();
	} else {
		return "";
	}
}

String FileAccessEncryptedv3::get_path_absolute() const {
	if (file.is_valid()) {
		return file->get_path_absolute();
	} else {
		return "";
	}
}

void FileAccessEncryptedv3::seek(uint64_t p_position) {
	if (p_position > get_length()) {
		p_position = get_length();
	}

	pos = p_position;
	eofed = false;
}

void FileAccessEncryptedv3::seek_end(int64_t p_position) {
	seek(get_length() + p_position);
}

uint64_t FileAccessEncryptedv3::get_position() const {
	return pos;
}

uint64_t FileAccessEncryptedv3::get_length() const {
	return data.size();
}

bool FileAccessEncryptedv3::eof_reached() const {
	return eofed;
}

uint8_t FileAccessEncryptedv3::get_8() const {
	ERR_FAIL_COND_V_MSG(writing, 0, "File has not been opened in read mode.");
	if (pos >= get_length()) {
		eofed = true;
		return 0;
	}

	uint8_t b = data[pos];
	pos++;
	return b;
}

uint64_t FileAccessEncryptedv3::get_buffer(uint8_t *p_dst, uint64_t p_length) const {
	ERR_FAIL_COND_V(!p_dst && p_length > 0, -1);
	ERR_FAIL_COND_V_MSG(writing, -1, "File has not been opened in read mode.");

	uint64_t to_copy = MIN(p_length, get_length() - pos);
	for (uint64_t i = 0; i < to_copy; i++) {
		p_dst[i] = data[pos++];
	}

	if (to_copy < p_length) {
		eofed = true;
	}

	return to_copy;
}

Error FileAccessEncryptedv3::get_error() const {
	return eofed ? ERR_FILE_EOF : OK;
}

void FileAccessEncryptedv3::store_buffer(const uint8_t *p_src, uint64_t p_length) {
	ERR_FAIL_COND_MSG(!writing, "File has not been opened in write mode.");
	ERR_FAIL_COND(!p_src && p_length > 0);

	if (pos < get_length()) {
		for (uint64_t i = 0; i < p_length; i++) {
			store_8(p_src[i]);
		}
	} else if (pos == get_length()) {
		data.resize(pos + p_length);
		for (uint64_t i = 0; i < p_length; i++) {
			data.write[pos + i] = p_src[i];
		}
		pos += p_length;
	}
}

void FileAccessEncryptedv3::flush() {
	ERR_FAIL_COND_MSG(!writing, "File has not been opened in write mode.");

	// encrypted files keep data in memory till close()
}

void FileAccessEncryptedv3::store_8(uint8_t p_dest) {
	ERR_FAIL_COND_MSG(!writing, "File has not been opened in write mode.");

	if (pos < get_length()) {
		data.write[pos] = p_dest;
		pos++;
	} else if (pos == get_length()) {
		data.push_back(p_dest);
		pos++;
	}
}

bool FileAccessEncryptedv3::file_exists(const String &p_name) {
	Ref<FileAccess> fa = FileAccess::open(p_name, FileAccess::READ);
	if (fa.is_null()) {
		return false;
	}
	return true;
}

uint64_t FileAccessEncryptedv3::_get_modified_time(const String &p_file) {
	return 0;
}

uint32_t FileAccessEncryptedv3::_get_unix_permissions(const String &p_file) {
	return 0;
}

Error FileAccessEncryptedv3::_set_unix_permissions(const String &p_file, uint32_t p_permissions) {
	ERR_PRINT("Setting UNIX permissions on encrypted files is not implemented yet.");
	return ERR_UNAVAILABLE;
}

void FileAccessEncryptedv3::close() {
	_close();
}

FileAccessEncryptedv3::~FileAccessEncryptedv3() {
	_close();
}
