#include "pcfg_loader.h"
#include "compat/variant_decoder_compat.h"
#include "compat/variant_writer_compat.h"

#include "core/config/engine.h"
#include "core/input/input_event.h"
#include "core/io/compression.h"
#include "core/io/file_access.h"
#include "core/io/marshalls.h"
#include "core/os/keyboard.h"
#include "core/variant/variant_parser.h"
#include <core/templates/rb_set.h>

Error ProjectConfigLoader::load_cfb(const String path, const uint32_t ver_major, const uint32_t ver_minor) {
	cfb_path = path;
	Error err = OK;
	Ref<FileAccess> f = FileAccess::open(path, FileAccess::READ, &err);
	ERR_FAIL_COND_V_MSG(f.is_null(), err, "Could not open " + path);
	err = _load_settings_binary(f, path, ver_major);
	ERR_FAIL_COND_V(err, err);
	loaded = true;
	return OK;
}

Error ProjectConfigLoader::save_cfb(const String dir, const uint32_t ver_major, const uint32_t ver_minor) {
	ERR_FAIL_COND_V_MSG(!loaded, ERR_INVALID_DATA, "Attempted to save project config when not loaded!");
	String file;
	if (ver_major > 2) {
		file = "project.godot";
	} else {
		file = "engine.cfg";
	}

	return save_custom(dir.path_join(file).replace("res://", ""), ver_major, ver_minor);
}

bool ProjectConfigLoader::has_setting(String p_var) const {
	return props.has(p_var);
}

Variant ProjectConfigLoader::get_setting(String p_var, Variant default_value) const {
	if (props.has(p_var)) {
		return props[p_var].variant;
	}
	return default_value;
}

Error ProjectConfigLoader::remove_setting(String p_var) {
	if (props.has(p_var)) {
		props.erase(p_var);
		return OK;
	}
	return ERR_FILE_NOT_FOUND;
}

Error ProjectConfigLoader::set_setting(String p_var, Variant value) {
	if (props.has(p_var)) {
		props[p_var].variant = value;
		return OK;
	}
	return ERR_FILE_NOT_FOUND;
}

Error ProjectConfigLoader::_load_settings_binary(Ref<FileAccess> f, const String &p_path, uint32_t ver_major) {
	Error err;
	uint8_t hdr[4];
	int file_length = f->get_length();
	int bytes_read = f->get_buffer(hdr, 4);
	if (hdr[0] != 'E' || hdr[1] != 'C' || hdr[2] != 'F' || hdr[3] != 'G') {
		ERR_FAIL_V_MSG(ERR_FILE_CORRUPT, "Corrupted header in binary project.binary (not ECFG).");
	} else if (bytes_read < 4) {
		WARN_PRINT("Bytes read less than slen!");
	}

	uint32_t count = f->get_32();

	for (uint32_t i = 0; i < count; i++) {
		uint32_t slen = f->get_32();
		CharString cs;
		cs.resize(slen + 1);
		cs[slen] = 0;
		int bytes_read = f->get_buffer((uint8_t *)cs.ptr(), slen);
		if (bytes_read < slen) {
			WARN_PRINT("Bytes read less than slen!");
		}
		String key;
		key.parse_utf8(cs.ptr());

		uint32_t vlen = f->get_32();
		Vector<uint8_t> d;
		d.resize(vlen);
		f->get_buffer(d.ptrw(), vlen);
		Variant value;
		err = VariantDecoderCompat::decode_variant_compat(ver_major, value, d.ptr(), d.size(), NULL, true);
		ERR_CONTINUE_MSG(err != OK, "Error decoding property: " + key + ".");
		props[key] = VariantContainer(value, last_builtin_order++, true);
	}
	cfb_path = p_path;
	return OK;
}

struct _VCSort {
	String name;
	Variant::Type type;
	int order;
	int flags;

	bool operator<(const _VCSort &p_vcs) const { return order == p_vcs.order ? name < p_vcs.name : order < p_vcs.order; }
};

Error ProjectConfigLoader::save_custom(const String &p_path, const uint32_t ver_major, const uint32_t ver_minor) {
	ERR_FAIL_COND_V_MSG(p_path == "", ERR_INVALID_PARAMETER, "Project settings save path cannot be empty.");

	RBSet<_VCSort> vclist;

	for (RBMap<StringName, VariantContainer>::Element *G = props.front(); G; G = G->next()) {
		const VariantContainer *v = &G->get();

		if (v->hide_from_editor)
			continue;

		_VCSort vc;
		vc.name = G->key(); //*k;
		vc.order = v->order;
		vc.type = v->variant.get_type();
		vc.flags = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_STORAGE;
		if (v->variant == v->initial)
			continue;

		vclist.insert(vc);
	}
	RBMap<String, List<String>> proops;

	for (RBSet<_VCSort>::Element *E = vclist.front(); E; E = E->next()) {
		String category = E->get().name;
		String name = E->get().name;

		int div = category.find("/");

		if (div < 0)
			category = "";
		else {
			category = category.substr(0, div);
			name = name.substr(div + 1, name.size());
		}
		proops[category].push_back(name);
	}

	return _save_settings_text(p_path, proops, ver_major, ver_minor);
}

Error ProjectConfigLoader::_save_settings_text(const String &p_file, const RBMap<String, List<String>> &proops, const uint32_t ver_major, const uint32_t ver_minor) {
	Error err;
	Ref<FileAccess> file = FileAccess::open(p_file, FileAccess::WRITE, &err);
	uint32_t config_version = 2;
	if (ver_major > 2) {
		if (ver_major == 3 && ver_minor == 0) {
			config_version = 3;
		} else if (ver_major == 3) {
			config_version = 4;
		} else { // v4
			config_version = 5;
		}
	} else {
		config_version = 2;
	}

	ERR_FAIL_COND_V_MSG(err != OK, err, "Couldn't save project.godot - " + p_file + ".");

	if (config_version > 2) {
		file->store_line("; Engine configuration file.");
		file->store_line("; It's best edited using the editor UI and not directly,");
		file->store_line("; since the parameters that go here are not all obvious.");
		file->store_line(";");
		file->store_line("; Format:");
		file->store_line(";   [section] ; section goes between []");
		file->store_line(";   param=value ; assign values to parameters");
		file->store_line("");

		file->store_string("config_version=" + itos(config_version) + "\n");
	}

	file->store_string("\n");

	for (RBMap<String, List<String>>::Element *E = proops.front(); E; E = E->next()) {
		if (E != proops.front())
			file->store_string("\n");

		if (E->key() != "")
			file->store_string("[" + E->key() + "]\n\n");
		for (List<String>::Element *F = E->get().front(); F; F = F->next()) {
			String key = F->get();
			if (E->key() != "")
				key = E->key() + "/" + key;
			Variant value;
			value = props[key].variant;

			String vstr;
			VariantWriterCompat::write_to_string_pcfg(value, vstr, ver_major);
			file->store_string(F->get().property_name_encode() + "=" + vstr + "\n");
		}
	}
	print_line("Saved project config to " + p_file);
	return OK;
}

ProjectConfigLoader::ProjectConfigLoader() {
}

ProjectConfigLoader::~ProjectConfigLoader() {
}
