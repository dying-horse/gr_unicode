#include <lauxlib.h>
#include <lua.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <wctype.h>


/* char-related function */

static int
unicode_cmp(lua_State *L) {
 wchar_t *wc_1 = luaL_checkudata(L, -2, "gr_unicode_wc");
 wchar_t *wc_2 = luaL_checkudata(L, -1, "gr_unicode_wc");

 if (!wc_1)
  return luaL_error(L, "cmp on wc: first arg is not an acceptable userdata");

 if (!wc_2)
  return luaL_error(L, "cmp on wc: sec arg is not an acceptable userdata");

 int cmp = wmemcmp(wc_1, wc_2, 1);
 lua_pop(L, 2);

 return cmp;
}

static int
unicode_eq(lua_State *L) {

 if (unicode_cmp(L))
  lua_pushboolean(L, 0);
 else
  lua_pushboolean(L, 1);

 return 1;
}

static int
unicode_lt(lua_State *L) {

 if (unicode_cmp(L) < 0)
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 return 1;
}

static int
unicode_le(lua_State *L) {

 if (unicode_cmp(L) <= 0)
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 return 1;
}

static int
unicode_tostring(lua_State *L) {
 char mb[MB_CUR_MAX + 1];
 int nr = wctomb(mb, *((wchar_t *) luaL_checkudata(L, -1, "gr_unicode_wc")));

 lua_pop(L, 1);

 if (nr > 0)
  lua_pushlstring(L, mb, nr);

 if (nr == -1)
  return luaL_error(L, "wc cannot be interpreted as mb");

 return 1;
}

static wchar_t *
unicode_newwc(lua_State *L) {
 wchar_t *wc = lua_newuserdata(L, sizeof(wchar_t));

 luaL_newmetatable(L, "gr_unicode_wc");

 lua_pushstring(L, "__eq");
 lua_pushcfunction(L, &unicode_eq);
 lua_settable(L, -3);

 lua_pushstring(L, "__lt");
 lua_pushcfunction(L, &unicode_lt);
 lua_settable(L, -3);

 lua_pushstring(L, "__le");
 lua_pushcfunction(L, &unicode_le);
 lua_settable(L, -3);

 lua_pushstring(L, "__tostring");
 lua_pushcfunction(L, &unicode_tostring);
 lua_settable(L, -3);

 lua_setmetatable(L, -2);
 return wc;
}

static int
unicode_towc(lua_State *L) {
 size_t len;
 const char *str = luaL_checklstring(L, -1, &len);

 if (!str)
  return luaL_error(L, "unicode.towc: unsuitable arg");

 wchar_t *wc = unicode_newwc(L);
 int     ret = mbtowc(wc, str, len);

 lua_remove(L, -2);

 if (!ret)
  return luaL_error(L, "unicode.towc: empty string arg");

 if (ret < 0)
  return luaL_error(L, "unicode.towc: input cannot be interpreted as wc");

 return 1;
}

static int
unicode_isalnum(lua_State *L) {
 if (iswalnum(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_isalpha(lua_State *L) {
 if (iswalpha(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_iscntrl(lua_State *L) {
 if (iswcntrl(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_isdigit(lua_State *L) {
 if (iswdigit(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_isgraph(lua_State *L) {
 if (iswgraph(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_islower(lua_State *L) {
 if (iswlower(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_isprint(lua_State *L) {
 if (iswprint(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_ispunct(lua_State *L) {
 if (iswpunct(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_isspace(lua_State *L) {
 if (iswspace(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_isupper(lua_State *L) {
 if (iswupper(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_isxdigit(lua_State *L) {
 if (iswxdigit(*((wint_t *) luaL_checkudata(L, -1, "gr_unicode_wc"))))
  lua_pushboolean(L, 1);
 else
  lua_pushboolean(L, 0);

 lua_remove(L, -2);

 return 1;
}

static int
unicode_tolower(lua_State *L) {
 wchar_t *wc_res = unicode_newwc(L);

 *wc_res = towlower(*((wint_t *) luaL_checkudata(L, -2, "gr_unicode_wc")));
 lua_remove(L, -2);

 return 1;
}

static int
unicode_toupper(lua_State *L) {
 wchar_t *wc_res = unicode_newwc(L);

 *wc_res = towupper(*((wint_t *) luaL_checkudata(L, -2, "gr_unicode_wc")));
 lua_remove(L, -2);

 return 1;
}


/* Char-buffer-related functions */

typedef struct {
 mbstate_t  mbstate;
 int        pointer;
} unicode_bufstate_t;

static unicode_bufstate_t *
unicode_newbufstate(lua_State *L) {
 unicode_bufstate_t *bs = lua_newuserdata(L, sizeof(unicode_bufstate_t));
 bzero((void *) &(bs -> mbstate), sizeof(mbstate_t));

 luaL_newmetatable(L, "gr_unicode_bufstate");
 lua_setmetatable(L, -2);

 return bs;
}

static int
unicode_mbb_except_invalid_mb(lua_State *L) {
 lua_pop(L, 1);

 luaL_error(L, "could not scan a wc");

 return 0;
}

static int
unicode_mbb_push(lua_State *L) {

 lua_setfield(L, -2, "buf");

 lua_getfield(L, -1, "bufstate");

 { unicode_bufstate_t *bs = luaL_checkudata(L, -1,"gr_unicode_bufstate");
   bs -> pointer = 0;
 }

 lua_setfield(L, -2, "bufstate");
 lua_pop(L, 1);

 return 0;
}

static int
unicode_mbb_go(lua_State *L) {
 int   len;
 lua_getfield(L, -1, "buf");
 const char *buf = luaL_checklstring(L, -1, &len);

 wchar_t *wc = unicode_newwc(L);

 lua_getfield(L, -3, "bufstate");
 unicode_bufstate_t *bs = luaL_checkudata(L, -1, "gr_unicode_bufstate");

 int rem = len - (bs -> pointer);

 if (!rem) {
  lua_pop(L, 4);
  lua_pushstring(L, "push");
  return 1;
 }

 int ret = mbrtowc(wc, buf + (bs -> pointer), rem, &(bs -> mbstate));

 if (ret == (size_t) -2) {
  lua_pop(L, 4);
  lua_pushstring(L, "push");
  return 1;
 }

 if (ret == (size_t) -1) {
  lua_pop(L, 3);

  lua_getfield(L, -1, "except_invalid_mb");
  lua_insert(L, -2);
  lua_call(L, 1, 0);

  lua_pushstring(L, "err");

  return 1;
 }

 bs -> pointer += ret;
 lua_setfield(L, -4, "bufstate");
  
 lua_pushstring(L, "ok");
 lua_insert(L, -2);
 lua_remove(L, -3);
 lua_remove(L, -3);

 return 2;
}

static int
unicode_mbb_getblk(lua_State *L) {
 int   len;
 lua_getfield(L, -1, "buf");
 const char *buf = luaL_checklstring(L, -1, &len);

 lua_getfield(L, -2, "bufstate");
 unicode_bufstate_t *bs = luaL_checkudata(L, -1, "gr_unicode_bufstate");

 lua_pushlstring(L, buf + (bs -> pointer), len - (bs -> pointer));

 lua_remove(L, -2);
 lua_remove(L, -2);
 lua_remove(L, -2);

 return 1;
}

static int
unicode_mbb_new(lua_State *L) {
 lua_createtable(L, 0, 1);

 unicode_bufstate_t *bs = unicode_newbufstate(L);

 lua_setfield(L, -2, "bufstate");

 lua_createtable(L, 0, 1);
 lua_getglobal(L, "unicode");
 lua_getfield(L, -1, "mbb");
 lua_setfield(L, -3, "__index");
 lua_pop(L, 1);
 lua_setmetatable(L, -2);

 return 1;
}


/* General */

static luaL_Reg
unicode_funcs[] = {
 { "towc", &unicode_towc },
 { "isalnum", &unicode_isalnum },
 { "isalpha", &unicode_isalpha },
 { "iscntrl", &unicode_iscntrl },
 { "isdigit", &unicode_isdigit },
 { "isgraph", &unicode_isgraph },
 { "islower", &unicode_islower },
 { "isprint", &unicode_isprint },
 { "ispunct", &unicode_ispunct },
 { "isspace", &unicode_isspace },
 { "isupper", &unicode_isupper },
 { "isxdigit", &unicode_isxdigit },
 { "tolower", &unicode_tolower },
 { "toupper", &unicode_toupper },
 { NULL, NULL }
};

int
luaopen_unicode_aux(lua_State *L) {
 luaL_register(L, "unicode", unicode_funcs);


 /* Create object mbb. */

 lua_getglobal(L, "unicode");
 lua_createtable(L, 0, 5);

 lua_pushcfunction(L, &unicode_mbb_except_invalid_mb);
 lua_setfield(L, -2, "except_invalid_mb");

 lua_pushcfunction(L, &unicode_mbb_push);
 lua_setfield(L, -2, "push");

 lua_pushcfunction(L, &unicode_mbb_go);
 lua_setfield(L, -2, "go");

 lua_pushcfunction(L, &unicode_mbb_getblk);
 lua_setfield(L, -2, "getblk");

 lua_pushcfunction(L, &unicode_mbb_new);
 lua_setfield(L, -2, "new");

 lua_setfield(L, -2, "mbb");

 return 0;
}

