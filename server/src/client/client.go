package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	//"io/ioutil"
	"log"
	"net/http"
	"time"
)

type Tag int

const (
	FactoryTag Tag = iota
	RobotTag
	MineTag
)

type Id int
type ClientId int

type MessageType int

const (
	Spawn   MessageType = iota //0
	Move                       //1
	Attack                     //2
	Destroy                    //3
)

type Message struct {
	What     MessageType
	Tag      Tag
	Id       Id
	ClientId ClientId
	X        float64
	Y        float64
}

type MessageList struct {
	Number   int
	Messages []Message
}

func main() {

	// try to join
	fmt.Println("starting the join request")
	var clientId ClientId
	start := time.Now()
	var message Message
	resp, err := http.Get("http://localhost:5000/join")
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println(resp.Status)
	//b, _ := ioutil.ReadAll(resp.Body)
	//fmt.Printf("the json: %s\n", string(b))
	dec := json.NewDecoder(resp.Body)
	err = dec.Decode(&message)
	if err != nil {
		fmt.Println("error decoding the response to the join request")
		log.Fatal(err)
	}

	fmt.Println(message)
	duration := time.Since(start)
	fmt.Println("connected after: ", duration)
	fmt.Println("with clientId", message.ClientId)

	// now that we are connected to the server
	// we can start to communicate
	// first create a message
	// this is a spawn request. tag is 0 -> factory
	// we are sending an invalid id
	// the coordinates are 100,100
	fmt.Println("starting the request request")
	message = Message{0, 0, -1, clientId, 100, 100}
	start = time.Now()
	var buffer bytes.Buffer
	enc := json.NewEncoder(&buffer)

	err = enc.Encode(message)
	if err != nil {
		fmt.Println("error encoding the message")
		log.Fatal(err)
	}

	fmt.Printf("the json: %s\n", buffer.Bytes())
	resp, err = http.Post("http://localhost:5000/request", "application/json", &buffer)
	if err != nil {
		fmt.Println("error posting the message")
		log.Fatal(err)
	}

	duration = time.Since(start)
	fmt.Println("sent a message to the server")
	fmt.Println("that took: ", duration)

	// the server has received a message
	// maybe it has not been processed, but it should be queued somewhere
	// let's try to get it back
	fmt.Println()
	fmt.Println("starting the update request")
	start = time.Now()
	// this will be a post request. the clientId is sent in the message
	message = Message{-1, -1, -1, clientId, -1, -1}

	enc = json.NewEncoder(&buffer)

	err = enc.Encode(message)
	if err != nil {
		fmt.Println("error encoding the message")
		log.Fatal(err)
	}
	fmt.Printf("the json: %s\n", buffer.Bytes())
	resp, err = http.Post("http://localhost:5000/update",
		"application/json", &buffer)
	if err != nil {
		fmt.Println("error posting the update request")
		log.Fatal(err)
	}

	var messageList MessageList
	dec = json.NewDecoder(resp.Body)
	err = dec.Decode(&messageList)
	if err != nil {
		fmt.Println("error decoding the update messagelist")
		log.Fatal(err)
	}

	duration = time.Since(start)
	fmt.Println("received updates after: ", duration)
	fmt.Printf("updates: %v\n", messageList)

}
