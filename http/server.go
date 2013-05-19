package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"http/vector2"
	"log"
	"net/http"
	"runtime"
	"sync"
	"time"
)

// types, structs and methods to handle the gameObejcts

// GameObject Tag
type Tag int

const (
	FactoryTag Tag = iota
	RobotTag
	MineTag
)

type Id int
type ClientId int

type GameObject interface {
	Update(deltaTime float32, requests chan Message)
	GetTag() Tag
	GetId() Id
	GetClientId() ClientId
	GetPos() vector2.Vector2
	SetTag(newTag Tag)
	SetId(newId Id)
	SetClientId(newClientId ClientId)
	SetPos(newPos vector2.Vector2)
}

type GameObjectData struct {
	Tag      Tag
	Id       Id
	ClientId ClientId
	Pos      vector2.Vector2
}

func (g *GameObjectData) GetTag() Tag {
	return g.Tag
}

func (g *GameObjectData) GetId() Id {
	return g.Id
}

func (g *GameObjectData) GetClientId() ClientId {
	return g.ClientId
}

func (g *GameObjectData) GetPos() vector2.Vector2 {
	return g.Pos
}

func (g *GameObjectData) SetTag(newTag Tag) {
	g.Tag = newTag
}

func (g *GameObjectData) SetId(newId Id) {
	g.Id = newId
}

func (g *GameObjectData) SetClientId(newClientId ClientId) {
	g.ClientId = newClientId
}

func (g *GameObjectData) SetPos(newPos vector2.Vector2) {
	g.Pos = newPos
}

type Robot struct {
	GameObjectData
}

func (robot *Robot) Update(deltaTime float32, messages chan Message) {
	//update-logic of a robot
}

type Factory struct {
	GameObjectData
}

func (factory *Factory) Update(deltaTime float32, messages chan Message) {
	//update-logic of a factory
}

//types, structs and methods to handle communication
// MessageType
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

type Game struct {
	GameObjects []GameObject
	Requests    chan Message
	LastCall    time.Time
	Network     *Network
}

// the update function is based on the Requests channel of the Game struct
// all GameObjects are updated with a goroutine that receives this channel
// as a parameter and can write requests to the channel
// after all GameObjects have been updated the message channel is emptied
// each processed message is passed to the Network object to be distributed
// to the clients
func (game *Game) Update() {
	// first: calculate the elapsed time
	// time.Since returns deltaTime in nanoseconds. we want seconds
	deltaTime := float32(time.Since(game.LastCall) / 1000000000)
	game.LastCall = time.Now()
	// now create a WaitGroup
	var wg sync.WaitGroup

	for _, gameObject := range game.GameObjects {
		// for each GameObject the WaitGroupt counter is incremented
		wg.Add(1)
		go func() {
			// defers the decrementation of the WaitGroup counter
			// till the function is finished
			defer wg.Done()
			gameObject.Update(deltaTime, game.Requests)
		}()
	}
	// this call to wg.Wait() blocks till the counter is back at 0
	wg.Wait()

	// the request channel has been filled with messages
	// got to empty it
	for message := range game.Requests {
		fmt.Println("processing a message from the games request channel")
		// let's take a look at the contents of the message
		clientId := message.ClientId
		id := message.Id
		tag := message.Tag
		what := message.What
		x := message.X
		y := message.Y
		fmt.Println(clientId, id, tag, what, x, y)
		// process the message

		// distribute the message
		game.Network.Distribute(message)

	}
}

//now the client
type Client struct {
	ClientId ClientId
	Outgoing chan Message
}

type Network struct {
	Game    *Game
	Clients []Client
}

func (network *Network) Distribute(message Message) {
	fmt.Println("distributing a message")
	for _, client := range network.Clients {
		fmt.Println("passing message to a client")
		client.Outgoing <- message
	}
}

func (network *Network) Join(
	w http.ResponseWriter,
	r *http.Request) {
	//the request is not interesting
	//the response will be a message with just the clientId value set
	log.Println("client wants to join")
	message := Message{-1, -1, -1, ClientId(len(network.Clients)), -1, -1}
	var buffer bytes.Buffer
	enc := json.NewEncoder(&buffer)

	err := enc.Encode(message)
	if err != nil {
		fmt.Println("error encoding the response to a join request")
		log.Fatal(err)
	}

	fmt.Printf("the json: %s\n", buffer.Bytes())
	w.Write(buffer.Bytes())

	var client Client
	client.ClientId = ClientId(len(network.Clients))
	client.Outgoing = make(chan Message, 1000)

	network.Clients = append(network.Clients, client)
}

func (network *Network) Request(
	w http.ResponseWriter,
	r *http.Request) {
	log.Println("incoming request message")
	header := r.Header // map[string][]string
	log.Println(header)

	var message Message
	err := json.NewDecoder(r.Body).Decode(&message)
	if err != nil {
		log.Fatal("couldn't decode the json", err)
	}
	log.Println(message.Y)
	network.Game.Requests <- message
	fmt.Println("message sent to game channel")
	fmt.Fprint(w, "you shouldn't expect an answer to a request! I hope this crashes your decoder")
}

func (network *Network) GetNews(
	w http.ResponseWriter,
	r *http.Request) {
	log.Println("client wants news")

	var message Message
	err := json.NewDecoder(r.Body).Decode(&message)
	if err != nil {
		log.Fatal("couldn't decode the json", err)
	}

	// we only need the clientId
	clientId := message.ClientId
	// now filter the networks list of client for the right one
	var client Client
	for _, suspect := range network.Clients {
		if suspect.ClientId == clientId {
			client = suspect
			break
		}
	}

	fmt.Println("the client is:", client)

	// now we need to encode all the news as JSON
	// let's store the data in a struct first
	var messageList MessageList
	messageList.Messages = make([]Message, 0, 1000)
	for {
		fmt.Println("in the loop")
		stop := false
		select {
		case message := <-client.Outgoing:
			fmt.Println("adding a message to messageloop")
			messageList.Number += 1
			messageList.Messages = append(messageList.Messages, message)
		default:
			fmt.Println("reached the end of the channel")
			stop = true
		}
		if stop {
			break
		}
	}
	fmt.Println("starting to encode the messagelist")
	var buffer bytes.Buffer
	enc := json.NewEncoder(&buffer)

	err2 := enc.Encode(messageList)
	if err2 != nil {
		fmt.Println("error encoding the messagelist")
		log.Fatal(err2)
	}

	fmt.Printf("the json: %s\n", buffer.Bytes())
	w.Write(buffer.Bytes())

}

func main() {
	runtime.GOMAXPROCS(2)
	log.Println("about to begin")
	v := vector2.Vector2{2, 3}
	v.Scale(3)
	var network = new(Network)
	var clients = make([]Client, 0, 10)
	network.Clients = clients

	var game = new(Game)
	var gameObjects = make([]GameObject, 0, 1000)
	game.GameObjects = gameObjects
	game.Requests = make(chan Message, 1000)

	network.Game = game
	game.Network = network

	go func() {
		for {
			game.Update()
			time.Sleep(1e6)
		}
	}()

	log.Println("starting the server")
	http.HandleFunc("/request", network.Request)
	http.HandleFunc("/update", network.GetNews)
	http.HandleFunc("/join", network.Join)
	log.Fatal(http.ListenAndServe("localhost:5000", nil))
}
