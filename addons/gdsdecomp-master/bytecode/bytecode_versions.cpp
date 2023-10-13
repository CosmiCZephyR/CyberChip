/*************************************************************************/
/* bytecode_versions.cpp                                                 */
/*************************************************************************/

#include "bytecode/bytecode_versions.h"

void register_decomp_versions() {
	ClassDB::register_class<GDScriptDecomp_f3f05dc>();
	ClassDB::register_class<GDScriptDecomp_506df14>();
	ClassDB::register_class<GDScriptDecomp_0b806ee>();
	ClassDB::register_class<GDScriptDecomp_8c1731b>();
	ClassDB::register_class<GDScriptDecomp_31ce3c5>();
	ClassDB::register_class<GDScriptDecomp_703004f>();
	ClassDB::register_class<GDScriptDecomp_8cab401>();
	ClassDB::register_class<GDScriptDecomp_e82dc40>();
	ClassDB::register_class<GDScriptDecomp_2185c01>();
	ClassDB::register_class<GDScriptDecomp_97f34a1>();
	ClassDB::register_class<GDScriptDecomp_be46be7>();
	ClassDB::register_class<GDScriptDecomp_65d48d6>();
	ClassDB::register_class<GDScriptDecomp_48f1d02>();
	ClassDB::register_class<GDScriptDecomp_30c1229>();
	ClassDB::register_class<GDScriptDecomp_7d2d144>();
	ClassDB::register_class<GDScriptDecomp_64872ca>();
	ClassDB::register_class<GDScriptDecomp_6174585>();
	ClassDB::register_class<GDScriptDecomp_23441ec>();
	ClassDB::register_class<GDScriptDecomp_7124599>();
	ClassDB::register_class<GDScriptDecomp_1add52b>();
	ClassDB::register_class<GDScriptDecomp_4ee82a2>();
	ClassDB::register_class<GDScriptDecomp_513c026>();
	ClassDB::register_class<GDScriptDecomp_23381a5>();
	ClassDB::register_class<GDScriptDecomp_85585c7>();
	ClassDB::register_class<GDScriptDecomp_ed80f45>();
	ClassDB::register_class<GDScriptDecomp_8b912d1>();
	ClassDB::register_class<GDScriptDecomp_62273e5>();
	ClassDB::register_class<GDScriptDecomp_f8a7c46>();
	ClassDB::register_class<GDScriptDecomp_c24c739>();
	ClassDB::register_class<GDScriptDecomp_5e938f0>();
	ClassDB::register_class<GDScriptDecomp_015d36d>();
	ClassDB::register_class<GDScriptDecomp_c6120e7>();
	ClassDB::register_class<GDScriptDecomp_d28da86>();
	ClassDB::register_class<GDScriptDecomp_216a8aa>();
	ClassDB::register_class<GDScriptDecomp_91ca725>();
	ClassDB::register_class<GDScriptDecomp_054a2ac>();
	ClassDB::register_class<GDScriptDecomp_ff1e7cf>();
	ClassDB::register_class<GDScriptDecomp_a56d6ff>();
	ClassDB::register_class<GDScriptDecomp_3ea6d9f>();
	ClassDB::register_class<GDScriptDecomp_8e35d93>();
	ClassDB::register_class<GDScriptDecomp_a3f1ee5>();
	ClassDB::register_class<GDScriptDecomp_8aab9a0>();
	ClassDB::register_class<GDScriptDecomp_d6b31da>();
	ClassDB::register_class<GDScriptDecomp_1ca61a3>();
	ClassDB::register_class<GDScriptDecomp_1a36141>();
	ClassDB::register_class<GDScriptDecomp_514a3fb>();
	ClassDB::register_class<GDScriptDecomp_7f7d97f>();
	ClassDB::register_class<GDScriptDecomp_620ec47>();
	ClassDB::register_class<GDScriptDecomp_c00427a>();
	ClassDB::register_class<GDScriptDecomp_a60f242>();
	ClassDB::register_class<GDScriptDecomp_6694c11>();
	ClassDB::register_class<GDScriptDecomp_5565f55>();
	ClassDB::register_class<GDScriptDecomp_a7aad78>();
}

GDScriptDecomp *create_decomp_for_commit(uint64_t p_commit_hash) {
	switch (p_commit_hash) {
		case 0x0b806ee:
			return memnew(GDScriptDecomp_0b806ee);
		case 0x8c1731b:
			return memnew(GDScriptDecomp_8c1731b);
		case 0x31ce3c5:
			return memnew(GDScriptDecomp_31ce3c5);
		case 0x703004f:
			return memnew(GDScriptDecomp_703004f);
		case 0x8cab401:
			return memnew(GDScriptDecomp_8cab401);
		case 0xe82dc40:
			return memnew(GDScriptDecomp_e82dc40);
		case 0x2185c01:
			return memnew(GDScriptDecomp_2185c01);
		case 0x97f34a1:
			return memnew(GDScriptDecomp_97f34a1);
		case 0xbe46be7:
			return memnew(GDScriptDecomp_be46be7);
		case 0x65d48d6:
			return memnew(GDScriptDecomp_65d48d6);
		case 0x48f1d02:
			return memnew(GDScriptDecomp_48f1d02);
		case 0x30c1229:
			return memnew(GDScriptDecomp_30c1229);
		case 0x7d2d144:
			return memnew(GDScriptDecomp_7d2d144);
		case 0x64872ca:
			return memnew(GDScriptDecomp_64872ca);
		case 0x6174585:
			return memnew(GDScriptDecomp_6174585);
		case 0x23441ec:
			return memnew(GDScriptDecomp_23441ec);
		case 0x7124599:
			return memnew(GDScriptDecomp_7124599);
		case 0x1add52b:
			return memnew(GDScriptDecomp_1add52b);
		case 0x4ee82a2:
			return memnew(GDScriptDecomp_4ee82a2);
		case 0x513c026:
			return memnew(GDScriptDecomp_513c026);
		case 0x23381a5:
			return memnew(GDScriptDecomp_23381a5);
		case 0x85585c7:
			return memnew(GDScriptDecomp_85585c7);
		case 0xed80f45:
			return memnew(GDScriptDecomp_ed80f45);
		case 0x8b912d1:
			return memnew(GDScriptDecomp_8b912d1);
		case 0x62273e5:
			return memnew(GDScriptDecomp_62273e5);
		case 0xf8a7c46:
			return memnew(GDScriptDecomp_f8a7c46);
		case 0xc24c739:
			return memnew(GDScriptDecomp_c24c739);
		case 0x5e938f0:
			return memnew(GDScriptDecomp_5e938f0);
		case 0x015d36d:
			return memnew(GDScriptDecomp_015d36d);
		case 0xc6120e7:
			return memnew(GDScriptDecomp_c6120e7);
		case 0xd28da86:
			return memnew(GDScriptDecomp_d28da86);
		case 0x216a8aa:
			return memnew(GDScriptDecomp_216a8aa);
		case 0x91ca725:
			return memnew(GDScriptDecomp_91ca725);
		case 0x054a2ac:
			return memnew(GDScriptDecomp_054a2ac);
		case 0xff1e7cf:
			return memnew(GDScriptDecomp_ff1e7cf);
		case 0xa56d6ff:
			return memnew(GDScriptDecomp_a56d6ff);
		case 0x3ea6d9f:
			return memnew(GDScriptDecomp_3ea6d9f);
		case 0x8e35d93:
			return memnew(GDScriptDecomp_8e35d93);
		case 0xa3f1ee5:
			return memnew(GDScriptDecomp_a3f1ee5);
		case 0x8aab9a0:
			return memnew(GDScriptDecomp_8aab9a0);
		case 0xd6b31da:
			return memnew(GDScriptDecomp_d6b31da);
		case 0x1ca61a3:
			return memnew(GDScriptDecomp_1ca61a3);
		case 0x1a36141:
			return memnew(GDScriptDecomp_1a36141);
		case 0x514a3fb:
			return memnew(GDScriptDecomp_514a3fb);
		case 0x7f7d97f:
			return memnew(GDScriptDecomp_7f7d97f);
		case 0x620ec47:
			return memnew(GDScriptDecomp_620ec47);
		case 0xc00427a:
			return memnew(GDScriptDecomp_c00427a);
		case 0xa60f242:
			return memnew(GDScriptDecomp_a60f242);
		case 0x6694c11:
			return memnew(GDScriptDecomp_6694c11);
		case 0x5565f55:
			return memnew(GDScriptDecomp_5565f55);
		case 0xa7aad78:
			return memnew(GDScriptDecomp_a7aad78);
		case 0x506df14:
			return memnew(GDScriptDecomp_506df14);
		case 0xf3f05dc:
			return memnew(GDScriptDecomp_f3f05dc);
		default:
			return NULL;
	}
}