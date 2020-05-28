extends KinematicBody2D

export (int) var detect_radius  # Deixa que cada torreta criada tenha um "range" único (selecionavel no inspector).
export (Resource) var sprite
export (int) var velocidade

var target
var hit_pos


func _ready():
	var shape = CircleShape2D.new() 
	shape.radius = detect_radius  # Cria o "range" com o raio selecionado.
	$Alcance/CollisionShape2D.shape = shape  # Coloca o "range" na torreta.
	$Sprite.texture = sprite

func _physics_process(delta):  # Loop principal da torreta.
	update()
	if target:  # Se tem um alvo, então mire nele.
		aim()

func aim():
	hit_pos = []  # Uma lista que terá todas as posições das bordas do player.
	var velocity = Vector2.ZERO
	var space_state = get_world_2d().direct_space_state
	var target_extents = target.get_node('CollisionShape2D').shape.extents - Vector2(5, 5)
	var nw = target.position - target_extents  # coordenada para o canto superior esquerdo do player
	var se = target.position + target_extents  # canto superior direito
	var ne = target.position + Vector2(target_extents.x, -target_extents.y)  # canto inferior direito.
	var sw = target.position + Vector2(-target_extents.x, target_extents.y)  # canto inferior esquerdo.
	for pos in [target.position, nw, ne, se, sw]:  # Loop que vai criar todas as "miras" da torreta.
		var result = space_state.intersect_ray(position,
				pos, [self], collision_mask)
		if result:
			hit_pos.append(result.position)
			if result.collider.name == "Player":  # Fazer isso apenas se o alvo for "player": # Deixa a sprite com suas cores normais.
				rotation = (target.position - position).angle()  # Girar a maquina na direção do alvo.
				var direcao = (target.global_position - global_position).normalized()
				velocity = velocity.move_toward(direcao * velocidade, velocidade)
				break
			else:
				velocity = Vector2.ZERO
	velocity = move_and_slide(velocity)

func _on_Alcance_body_entered(body):
	if target:  # Se já tinha um alvo, então ignorar.
		return
	target = body  # Se chegou até aqui, ainda não tinha alvo, e o novo alvo agora é quem entrou no range.


func _on_Alcance_body_exited(body):
	if body == target:  # Se quem saiu era o alvo:
		target = null  # Definir que o alvo agora é ninguém.
