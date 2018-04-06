#lang racket

(require web-server/servlet-env
         web-server/servlet)

;; 1 Euro svarer ca. til 7,456 DKK.
(define conversion-rate 7.456)

;; Beregn beløbet i Euro som svarer til beløb i DKK.
(define (dkk->euro dkk)
  (/ dkk conversion-rate))

;; Giv et pænt svar når brugeren spørger.
(define (my-response dkk)
  (define euro (dkk->euro dkk))
  (format "~a DKK svarer til ~a Euro." dkk euro))

;; Læs en værdi for et given id fra en request eller returner default
;; værdien hvis id'en ikke findes.
(define (get-binding id req default)
  (with-handlers ([exn:fail? (λ (e) default)])
    (let ([v (extract-binding/single (string->symbol id) (request-bindings req))])
      (if (and v (non-empty-string? v)) v default))))

;; App'en som udgør brugergrænsefladen.
;; Parametern "req" indeholder informationen som browseren sender til hjemmesiden.
(define (my-converter req)
  (define amount (string->number (get-binding "amount" req "1")))     ; Beløbet som brugeren har indtastet.
  (response/xexpr
   `(html (head (title "Codecafe Valutaberegner"))
          (body (p ,(my-response amount))          ; Dit svar.
                (p "Indtast beløb i danske kroner.")
                (p (form (input ([name "amount"])) ; Her indtaster brugeren beløbet.
                         (button "Beregn!")))))))  ; Dette er knappen som brugeren bør trykke.

(serve/servlet my-converter #:servlet-path "/codecafe/valuta")
