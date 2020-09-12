/*
 * Copyright 2020 Hayo van Loon
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
)

type handler struct {
	debug bool
}

func (h *handler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	log.Printf("%s %s",  r.Method, r.URL.Path)
	if h.debug {
		for h := range r.Header {
			log.Printf("  %s: %s", h, r.Header.Get(h))
		}
	}
	http.ServeFile(w, r, "files/" + r.URL.Path)
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	p := flag.String("port", port, "port to listen on")
	debug := flag.Bool("debug", false, "log more info from the incoming request")
	flag.Parse()

	fmt.Printf("Listening on port %s", *p)
	err := http.ListenAndServe(":"+*p, &handler{debug: *debug})
	if err != nil {
		log.Fatal(err)
	}
}
