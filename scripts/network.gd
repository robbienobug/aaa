extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

const PORTA = 9999
const PLAYERS_MAX = 6
var IP_PADRAO = "127.0.0.1"

var peer : ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var players = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _create_server(player_nickname: String):
	var err = peer.create_server(PORTA, PLAYERS_MAX)
	if err != OK:
		print("Erro ao Criar Servidor")
		return false
	multiplayer.multiplayer_peer = peer
	players[1]={
		"nickname":player_nickname,
		"player_id":1,
		"is_host":true
	}
	print("Servidor Criado com Sucesso na porta: ", PORTA)
	return true
	
func _create_client(ip: String, nickname: String):
	var err = peer.create_client(ip, PORTA)
	if err != OK:
		print("Erro ao Entrar no servidor")
		return false
	multiplayer.multiplayer_peer = peer
	print("Tentando se conectar: ", ip, ":", PORTA)
	return true

func _on_player_connected(peer_id):
	print("Jogador conectado: ", peer_id)
	if multiplayer.is_server():
		register_player.rpc_id(peer_id, players[1]["nickname"])
		
func _on_player_disconnected(peer_id):
	print("Jogador desconectado: ", peer_id)
	player_disconnected.emit(peer_id)
	
	if multiplayer.is_server():
		players.erase(peer_id)
		_remove_player.rpc(peer_id)
func _on_connected_to_server():
	print("Conectado ao Servidor")
	var peer_id = multiplayer.get_unique_id()
	print("Meu peer ID: ", peer_id)
	_request_join.rpc_id(1, players[peer_id]["nickname"])
	
func _on_connection_failed():
	print("Falhou a conexao")
	server_disconnected.emit()
	
func _on_server_disconnected():
	print("Desconectado do Servidor")
	server_disconnected.emit()
	
@rpc("any_peer", "call_local", "reliable")
func _request_join(nickname: String):
	var peer_id = multiplayer.get_remote_sender_id()
	
	for player in players.values():
		if player["nickname"] == nickname:
			peer.disconnect_peer(peer_id)
			return
	players[peer_id]={
		"nickname":nickname,
		"peer_id":peer_id,
		"is_host":false
	}
	
	print("Jogador Registrado: ", nickname)
	_sync_player.rpc_id(peer_id, players)
	
@rpc("authority", "call_local", "reliable")
func register_player(host_nickname: String):
	players[1]={
		"nickname":host_nickname,
		"peer_id":1,
		"is_host":true
	}
	
@rpc("authority", "call_local", "reliable")
func _sync_player(all_players: Dictionary):
	players = all_players
	print("Jogadores Sincronizados: ", players)

@rpc("authority", "call_local", "reliable")
func _remove_player(peer_id: int):
	if players.has(peer_id):
		players.erase(peer_id)
func get_player_info(peer_id: int)->Dictionary:
	return players.get(peer_id, {})

func is_server()->bool:
	return multiplayer.is_server()

func _disconnect_from_server():
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		multiplayer.multiplayer_peer = null
		players.clear()
		
