package main

import (
	"encoding/json"
	"net/url"
	"sync"
	"unsafe"

	"github.com/zserge/lorca"
)

/*
#include <stdio.h>
static inline int call_function(void* f) {
	int (*functionPtr)() = f;
	return (*functionPtr)();
}

static inline char* ruby_function_str_str_caller(void* f, char* c) {
	char* (*functionPtr)(char*) = f;
	return (*functionPtr)(c);
}
*/
import "C"

//export my_add
func my_add(a, b C.int) C.int {
	return C.int(int(a) + int(b))
}

//export bounce_string
func bounce_string(path *C.char) *C.char {
	return path
}

//export add_hello_to_start
func add_hello_to_start(str *C.char) *C.char {
	s := "hello " + string(C.GoString(str))
	return C.CString(s)
}

//export call_func
func call_func(f unsafe.Pointer) C.int {
	return C.call_function(f)
}

var mutex = &sync.Mutex{}
var lorcaCurrIndex = 0
var lorcaWindowMap = make(map[int]lorca.UI)

//export lorca_new_window
func lorca_new_window(url, dir *C.char, width, height C.int, chromeProcessArgsStr *C.char) C.int {
	//TODO: err handling
	var chromeProcessArgs []string
	json.Unmarshal([]byte(string(C.GoString(chromeProcessArgsStr))), &chromeProcessArgs)
	ui, _ := lorca.New(string(C.GoString(url)), string(C.GoString(dir)), int(width), int(height), chromeProcessArgs...)
	curr := lorcaCurrIndex
	mutex.Lock()
	lorcaCurrIndex++
	lorcaWindowMap[curr] = ui
	mutex.Unlock()
	return C.int(curr)
}

//export lorca_window_bind
func lorca_window_bind(id C.int, name *C.char, argsAmount C.int, f unsafe.Pointer) {
	ui := lorcaWindowMap[int(id)]
	ui.Bind(string(C.GoString(name)), func(str string) string {
		cstr := C.ruby_function_str_str_caller(f, C.CString(str))
		s := string(C.GoString(cstr))
		return s
	})
}

//export lorca_window_eval
func lorca_window_eval(id C.int, js *C.char) *C.char {
	jsonjsstr := string(C.GoString(js))
	ui := lorcaWindowMap[int(id)]
	value := ui.Eval("(async()=>JSON.stringify(await " + jsonjsstr + "))()")
	return C.CString(value.String())
}

//export lorca_get_all_window_ids
func lorca_get_all_window_ids() *C.char {
	keys := make([]int, 0, len(lorcaWindowMap))
	for k := range lorcaWindowMap {
		keys = append(keys, k)
	}
	jsonbytes, _ := json.Marshal(keys)
	return C.CString(string(jsonbytes))
}

//export lorca_close_window
func lorca_close_window(_id C.int) {
	id := int(_id)
	ui := lorcaWindowMap[id]
	ui.Close()
	delete(lorcaWindowMap, id)
}

//export lorca_load_file
func lorca_load_file(id C.int, path *C.char) {
	ui := lorcaWindowMap[int(id)]
	ui.Load(string(C.GoString(path)))
}

//export lorca_load_string
func lorca_load_string(id C.int, html *C.char) {
	ui := lorcaWindowMap[int(id)]
	ui.Load("data:text/html," + url.PathEscape(string(C.GoString(html))))
}

//export lorca_window_wait_for_done
func lorca_window_wait_for_done(id C.int) {
	ui := lorcaWindowMap[int(id)]
	<-ui.Done()
}

//export lorca_set_window_bounds
func lorca_set_window_bounds(id C.int, boundsstr *C.char) {
	ui := lorcaWindowMap[int(id)]
	var bounds lorca.Bounds
	json.Unmarshal([]byte(string(C.GoString(boundsstr))), &bounds)
	ui.SetBounds(bounds)
}

//export lorca_get_window_bounds
func lorca_get_window_bounds(id C.int) *C.char {
	ui := lorcaWindowMap[int(id)]
	bounds, _ := ui.Bounds()
	bytes, _ := json.Marshal(bounds)
	return C.CString(string(bytes))
}

func main() {

}
