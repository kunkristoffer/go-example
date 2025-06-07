package main

import (
	"flag"
	"log"
	"net/http"
)

func main() {
	// Parse command line flags.
	dsn := flag.String("dsn", "", "datasource name")
	flag.Parse()
	if *dsn == "" {
		flag.Usage()
		log.Fatal("required: -dsn")
	}

	initDB(dsn)

	r := setupRouter()

	log.Println("Server started at http://localhost:8080")
	err := http.ListenAndServe(":8080", r)
	if err != nil {
		log.Fatal("ListenAndServe error:", err)
	}
}
