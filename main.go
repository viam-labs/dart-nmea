package main

/*
#include <stdlib.h>
*/
import "C"
import (
	"bufio"
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"strings"

	"github.com/erh/gonmea/analyzer"
)

//export ParseData
func ParseData(byteArr []byte) *C.char {
	fmt.Println(string(byteArr))
	in := io.NopCloser(bytes.NewReader(byteArr))
	defer in.Close()

	parser, err := analyzer.NewParser()
	if err != nil {

		return C.CString(fmt.Sprintf("Error: %v", err))
	}

	reader := bufio.NewReader(in)
	for {
		line, _, err := reader.ReadLine()
		if err != nil {
			if errors.Is(err, io.EOF) {
				return nil
			}
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		line = []byte(strings.TrimSpace(string(line)))
		if len(line) == 0 {
			continue
		}
		msg, err := parser.ParseMessage(line)
		if err != nil {
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		md, err := json.MarshalIndent(msg, "", "  ")
		if err != nil {
			return C.CString(fmt.Sprintf("Error: %v", err))
		}
		fmt.Println(string(md))
		return C.CString(string(md))
	}
}

func main() {}
