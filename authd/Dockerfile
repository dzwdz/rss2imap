FROM golang:1.17

WORKDIR /app

COPY go.mod ./
RUN go mod download && go mod verify

COPY . .
RUN go build -v -o /bin/authd ./...

CMD ["/bin/authd"]
