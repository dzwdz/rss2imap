package main

import (
	"bufio"
	"log"
	"net"
	"strings"
)

func verifyPass(user, pass string) bool {
	log.Println(user)
	return pass == "dupa"
}

func handleConn(conn net.Conn) {
	defer conn.Close()

	reader := bufio.NewReader(conn)

	user, err := reader.ReadString('\n')
	if err != nil { return }
	user = strings.TrimSuffix(user, "\n")

	pass, err := reader.ReadString('\n')
	if err != nil { return }
	pass = strings.TrimSuffix(pass, "\n")

	if verifyPass(user, pass) {
		conn.Write([]byte("OK\n"))
	} else {
		conn.Write([]byte("BAD\n"))
	}
}

func main() {
	ln, err := net.Listen("tcp", ":1234")
	if err != nil {
		log.Fatal(err)
	}
	for {
		conn, err := ln.Accept()
		if err != nil {
			log.Fatal(err)
		}
		go handleConn(conn)
	}
}
