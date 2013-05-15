import socket
serversocket=socket.socket(socket.AF_INET,socket.SOCK_STREAM)
serversocket.bind(("localhost",8008))
serversocket.listen(5)
clients=[]
messages=[]
newmessages=[]



class Client:
	def __init__(self,client,addr):
		self.socket=client
		self.addr=addr

	def recv(self):
		data=self.socket.recv(1024)
		return data

	def send(self,messages):
		for message in messages:
			self.socket.send(message.encode("utf-8"))



while True:
    (client,addr)=serversocket.accept()
    clients.append(Client(client,addr))

    for client in clients:
    	data=client.recv()
    	if not data:
    		continue
    	message=data.decode("utf-8")
    	newmessages.append(message)

    for message in newmessages:
    	print(message)

    for client in clients:
    	client.send(newmessages)

    messages.extend(newmessages)
    newmessages=[]
