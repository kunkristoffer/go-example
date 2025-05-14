package main

import (
	"log"
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/kunkristoffer/go-example/model"
	"github.com/kunkristoffer/go-example/pages"
)

func setupRouter() http.Handler {
	r := chi.NewRouter()

	r.Get("/", handleIndex)
	r.Post("/send", handlePostMessage)

	return r
}

func handleIndex(w http.ResponseWriter, r *http.Request) {
	rows, err := db.Query(`SELECT id, content, created_at FROM messages ORDER BY created_at DESC LIMIT ?`, 10)
	if err != nil {
		return
	}
	defer rows.Close()

	var messages []model.Message
	for rows.Next() {
		var m model.Message
		err := rows.Scan(&m.ID, &m.Content, &m.CreatedAt)
		if err != nil {
			return
		}
		messages = append(messages, m)
	}

	err = pages.Index(messages).Render(r.Context(), w)
	if err != nil {
		log.Println("Templ render error:", err)
	}
}

func handlePostMessage(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Redirect(w, r, "/", http.StatusSeeOther)
		return
	}

	err := r.ParseForm()
	if err != nil {
		http.Error(w, "Invalid form data", http.StatusBadRequest)
		return
	}

	content := r.FormValue("message")
	if content != "" {
		_, err := db.Exec(`INSERT INTO messages (content) VALUES (?)`, content)
		if err != nil {
			log.Println("Insert error:", err)
		}
	}

	http.Redirect(w, r, "/", http.StatusSeeOther)
}
