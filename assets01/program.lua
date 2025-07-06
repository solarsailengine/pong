function engine.on_started()
	engine.createdefaultwindow()
	log("Starting Pong game...")
	log("Controls:")
	log("  Left paddle: W (up), S (down)")
	log("  Right paddle: UP (up), DOWN (down)")
	log("  Serve ball: SPACE")
	log("  Quit: Q")
	log("First to 11 points wins!")
end

function engine.on_keyboard(buffer)
	if buffer == 'q' then
		engine.requestshutdown()
	end
end