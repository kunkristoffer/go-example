package main

import (
	"log"
	"net/http"
)

func main() {
	initDB()

	r := setupRouter()

	log.Println("Server started at http://localhost:3000")
	err := http.ListenAndServe(":3000", r)
	if err != nil {
		log.Fatal("ListenAndServe error:", err)
	}
}
