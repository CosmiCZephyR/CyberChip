class_name HurtboxComponent
extends Node

signal damage_received

@export var health_component: HealthComponent

func receive_damage() -> int:
	return 0;


