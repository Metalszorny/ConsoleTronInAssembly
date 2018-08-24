
Code	Segment
	assume CS:Code, DS:Data, SS:Stack
	
Start:
	mov ax, Code
	mov DS, AX
VgaMode:					; Setting the display to VGA mode.
	mov ax, 13h				; Set BIOS service to VGA mode.
	int 10h					; Call BIOS service.
VideoMemory:				; Setting the video memory.
	mov ax, 0a000h			; Set the video start address.
	mov es, ax				; Set the start address to the video memory.
Initialize:					; Initialize the players.
							; Initialize red player.
	mov cx, 110				; Set x coordinate.
	mov si, cx				; Store the x coordinate into another register as the function's parameter.
	mov cx, 120				; Set y coordinate.
	mov di, cx				; Store the y coordinate into another register as the function's parameter.
	mov cl, 1				; Set the direction as the function's parameter.
	mov ch, 40				; Set red color as the function's parameter.
	call UpdatePlayerA		; Call the function to update the data of player A, no return value.
	mov di, offset playerA	; Set the address of the player A data to the register.
	mov al, 1				; Put 1 as life in a register.
	mov [di + 6], al		; Set life to the player data.
							; Initialize blue player.
	mov cx, 210				; Set x coordinate.
	mov si, cx				; Store the x coordinate into another register as the function's parameter.
	mov	cx, 120				; Set y coordinate.
	mov di, cx				; Store the y coordinate into another register as the function's parameter.
	mov cl, 3				; Set the direction as the function's parameter.
	mov ch, 10				; Set blue color as the function's parameter.
	call UpdatePlayerB		; Call the function to update the data of player B, no return value.
	mov di, offset playerB	; Set the address of the player B data to the register.
	mov al, 1				; Put 1 as life in a register.
	mov [di + 6], al		; Set life to the player data.
	xor dx, dx				; Zero out the dx register.
	push dx					; Push time (= 0) to stack.
	call Time				; Call the function to refresh time, no return value.
ReadInput:					; Reads the pressed input key.
	mov ah, 01h				; Set the BIOS service to read keyboard input status.
	int 16h					; Call BIOS service, return value expected.
	jnz Buttons				; Go to handling buttons if any was pushed.
	xor ax, ax				; Set the BIOS service to read system time.
	int 1ah					; Call BIOS service, return value expected.
	pop bx					; Read the last entry from the stack.
	push bx					; Write the read data to the stack.
	sub dx, bx				; Get the difference from the return value clock count and the stored clock count.
	cmp dx, 1				; Is the difference 1 between the clock counts?
	jc ReadInput			; Go to reading the pressed input key if the elapsed time is 0.
	call Time				; Call the function to refresh time, no return value.
	xor ax, ax				; Zero out the register.
	call Players			; Call the function to validate and redraw the players, return value expected.
	cmp ax, 2				; Is the return value 2, meaning one player's life got increased?
	jz EndMatch2			; Go to end the match if one player's life got increased.
	jmp ReadInput			; Go to reading the pressed input key (loop).
Time:						; Function to handle time tick.
	pop bx					; Read the last entry from stack.
	mov si, bx				; Store the value in another register.
	pop bx					; Read the next to last entry from the stack.
	xor ax, ax				; Set the BIOS service to read system time.
	int 1ah					; Call BIOS service, return value expected.
	push dx					; Store the low-order part of the clock count in the stack.
	push si					; Store the fist read value from the stack back in the stack.
	ret						; Return to the calling line.
Buttons:					; Handle the pushed buttons and continue the process accordingly.
	mov ah, 00h				; Set the BIOS service to read keyboard character.
	int 16h					; Call BIOS service, return value expected.
	cmp al, 27				; Check if the pushed key is the Escape key.
	jz EndMatch2			; Exit the application if the pushed key is the Escape key.
	cmp ah, 75				; Was the read input the Left Arrow key?
	jz AGoLeft				; Go to move player A left if the pushed key was the Left Arrow key.
	cmp ah, 77				; Was the read input the Right Arrow key?
	jz AGoRight				; Go to move player A right if the pushed key was the Right Arrow key.
	cmp ah, 72				; Was the read input the Up Arrow key?
	jz AGoUp				; Go to move player A up if the pushed key was the Up Arrow key.
	cmp ah, 80				; Was the read input the Down Arrow key?
	jz AGoDown				; Go to move player A down if the pushed key was the Down Arrow key.
	cmp al, "a"				; Was the read input the A key?
	jz BGoLeft				; Go to move player B left if the pushed key was the A key.
	cmp al, "A"				; Was the read input the A key?
	jz BGoLeft				; Go to move player B left if the pushed key was the A key.
	cmp al, "d"				; Was the read input the D key?
	jz BGoRight				; Go to move player B right if the pushed key was the D key.
	cmp al, "D"				; Was the read input the D key?
	jz BGoRight				; Go to move player B right if the pushed key was the D key.
	cmp al, "w"				; Was the read input the W key?
	jz BGoUp				; Go to move player B up if the pushed key was the W key.
	cmp al, "W"				; Was the read input the W key?
	jz BGoUp				; Go to move player B up if the pushed key was the W key.
	cmp al, "s"				; Was the read input the S key?
	jz BGoDown				; Go to move player B down if the pushed key was the S key.
	cmp al, "S"				; Was the read input the S key?
	jz BGoDown				; Go to move player B down if the pushed key was the S key.
	jmp ReadInput			; Go to input key reading (loop).
Players:					; Function to validate and redraw the players. (return ax=1=no player died, ax=2=a player died)
	call CheckAPosition2	; Call function to check if player's A position is valid, return value expected.
	call ReadPlayerA		; Call function to read the data of player A, return value expected.
	call DrawPixel			; Call function to draw player A at the new position, no return value.
	call CheckBPosition2	; Call function to check if player's B position is valid, return value expected.
	call ReadPlayerB		; Call function to read the data of player B, return value expected.
	call DrawPixel			; Call function to draw player B at the new position, no return value.
	mov di, offset playerB	; Set the address of the player B data to the register.
	mov al, [di + 6]		; Read the life of player A and store it in a register.
	mov di, offset playerA	; Set the address of the player A data to the register.
	mov bl, [di + 6]		; Read the life of player B and store it in a register.
	cmp al, 2				; Check if player B has an increased life.
	jz PlayerDied			; Go to setting 2 as a return value if the player has an increased life.
	cmp bl, 2				; Check if player A has an increased life.
	jz PlayerDied			; Go to setting 2 as a return value if the player has an increased life.
	mov ax, 1				; Set 1 as a return value.
	ret						; Return to the calling line.
PlayerDied:					; Function to set 2 as a return value.
	mov ax, 2				; Set 2 as a return value.
	ret						; Return to the calling line.
ReadInput2:					; Reads the pressed input key.
	jmp ReadInput			; Go to reading the pressed input key.
ExitApplication2:			; Exit the application.
	jmp ExitApplication3	; Go to exiting the application.
AGoLeft:					; Player A turn left.
	call ReadPlayerA		; Call function to read the data of player A, return value expected.
	cmp cl, 2				; Player A was facing right before?
	jz ReadInput3			; Go to reading pressed input key and don't turn.
	mov cl, 4				; Set the direction to left.
	call UpdatePlayerA		; Call the function to update the data of player A, no return value.
	jmp ReadInput			; Go to reading pressed input key.
AGoRight:					; Player A turn right.
	call ReadPlayerA		; Call function to read the data of player A, return value expected.
	cmp cl, 4				; Player A was facing left before?
	jz ReadInput3			; Go to reading pressed input key and don't turn.
	mov cl, 2				; Set the  direction to right.
	call UpdatePlayerA		; Call the function to update the data of player A, no return value.
	jmp ReadInput			; Go to reading pressed input key.
AGoUp:						; Player A turn up.
	call ReadPlayerA		; Call function to read the data of player A, return value expected.
	cmp cl, 3				; Player A was facing down before?
	jz ReadInput3			; Go to reading pressed input key and don't turn.
	mov cl, 1				; Set the direction to up.
	call UpdatePlayerA		; Call the function to update the data of player A, no return value.
	jmp ReadInput			; Go to reading pressed input key.
AGoDown:					; Player A turn down.
	call ReadPlayerA		; Call function to read the data of player A, return value expected.
	cmp cl, 1				; Player A was facing up before?
	jz ReadInput2			; Go to reading pressed input key and don't turn.
	mov cl, 3				; Set the direction to down.
	call UpdatePlayerA		; Call the function to update the data of player A, no return value.
	jmp ReadInput			; Go to reading pressed input key.
ReadInput3:					; Reads the pressed input key.
	jmp ReadInput2			; Go to reading the pressed input key.
ExitApplication3:			; Exit the application.
	jmp ExitApplication		; Go to exiting the application.
BGoLeft:					; Player B turn left.
	call ReadPlayerB		; Call function to read the data of player B, return value expected.
	cmp cl, 2				; Player B was facing right before?
	jz ReadInput2			; Go to reading pressed input key and don't turn.
	mov cl, 4				; Set the direction to left.
	call UpdatePlayerB		; Call the function to update the data of player B, no return value.
	jmp ReadInput			; Go to reading pressed input key.
BGoRight:					; Player B turn right.
	call ReadPlayerB		; Call function to read the data of player B, return value expected.
	cmp cl, 4				; Player B was facing left before?
	jz ReadInput2			; Go to reading pressed input key and don't turn.
	mov cl, 2				; Set the direction to right.
	call UpdatePlayerB		; Call the function to update the data of player B, no return value.
	jmp ReadInput			; Go to reading pressed input key.
BGoUp:						; Player B turn up.
	call ReadPlayerB		; Call function to read the data of player B, return value expected.
	cmp cl, 3				; Player B was facing down before?
	jz ReadInput3			; Go to reading pressed input key and don't turn.
	mov cl, 1				; Set the direction to up.
	call UpdatePlayerB		; Call the function to update the data of player B, no return value.
	jmp ReadInput			; Go to reading pressed input key.
BGoDown:					; Player B turn down.
	call ReadPlayerB		; Call function to read the data of player B, return value expected.
	cmp cl, 1				; Player B was facing up before?
	jz ReadInput3			; Go to reading pressed input key and don't turn.
	mov cl, 3				; Set the direction to down.
	call UpdatePlayerB		; Call the function to update the data of player B, no return value.
	jmp ReadInput			; Go to reading pressed input key.
EndMatch2:					; Handles the end of the match.
	jmp EndMatch			; Go to handle the end of the match.
DrawPixel:					; Function to draw a pixel in the specified location. (si<-x;di<-y;cl<-direction;ch<-color), no return value
							; Pixel = Y * 320 + X
	mov ax, di				; Store the y coordinate in a register.
	mov bx, 320				; Store 320 in a register.
	mul	bx					; Get the y position.
	add	ax, si				; Add the x coordinate to get the position.
	mov di, ax				; Store the position in a register.
	mov al, ch				; Store the color in a register.
	mov es:[di], al			; Sets the color of the pixel in the video memory.
	ret						; Return to the calling line.
ReadPlayerA:				; Reads the data of player A. return value: (si<-x;di<-y;cl<-direction;ch<-color)
	mov di, offset playerA	; Set the address of the player A data to the register.
	mov ax, [di]			; Read the x coordinate to a register.
	mov si, ax				; Store the x coordinate in another register.
	mov al, [di + 4]		; Read the direction to a register.
	xor cx, cx				; Zero out the register.
	mov cl, al				; Store the direction in another register.
	mov al, [di + 5]		; Read the color to a register.
	mov ch, al				; Store the color in another register.
	mov ax, [di + 2]		; Read the y coordinate to a register.
	mov di, ax				; Store the y coordinate in another register.
	ret						; Return to the calling line.
ReadPlayerB:				; Reads the data of player B. return value: (si<-x; di<-y; cl<-direction; ch<-color)
	mov di, offset playerB	; Set the address of the player B data to the register.
	mov ax, [di]			; Read the x coordinate to a register.
	mov si, ax				; Store the x coordinate in another register.
	mov al, [di + 4]		; Read the direction to a register.
	xor cx, cx				; Zero out the register.
	mov cl, al				; Store the direction in another register.
	mov al, [di + 5]		; Read the color to a register.
	mov ch, al				; Store the color in another register.
	mov ax, [di + 2]		; Read the y coordinate to a register.
	mov di, ax				; Store the y coordinate in another register.
	ret						; Return to the calling line.
CheckAPosition2:			; Function to check the position of player A if it's inside of the map.
	call CheckAPosition		; Call function to check the position of player A if it's inside of the map, return value expected.
	ret						; Return to the calling line, return value expected.
CheckBPosition2:			; Function to check the position of player B if it's inside of the map.
	call CheckBPosition		; Call function to check the position of player B if it's inside of the map, return value expected.
	ret						; Return to the calling line, return value expected.
UpdatePlayerA:				; Function to overwrite the saved data of player A with the parameter. (si->x; di->y; cl->direction; ch->color), no return value.
	mov dx, di				; Save the y position in another register.
	mov di, offset playerA	; Set the address of the player A data to the register.
	mov [di], si 			; Overwrite the x position.
	mov [di + 4], cl		; Overwrite the direction.
	mov [di + 5], ch		; Overwrite the color.
	mov [di + 2], dx		; Overwrite the y position.
	ret						; Return to the calling line.
UpdatePlayerB:				; Function to overwrite the saved data of player B with the parameter. (si->x; di->y; cl->direction; ch->color), no return value.
	mov dx, di				; Save the y position in another register.
	mov di, offset playerB	; Set the address of the player B data to the register.
	mov [di], si 			; Overwrite the x position.
	mov [di + 4], cl		; Overwrite the direction.
	mov [di + 5], ch		; Overwrite the color.
	mov [di + 2], dx		; Overwrite the y position.
	ret						; Return to the calling line.
CollisionHandler:			; Collision handler. Input(ax=1=a, ax=2=b) return(ax=1=true, ax=0=false)
	cmp ax, 1				; Was the function called with player A?
	jnz ReadPlayerB2		; Go to read the data in of player B if not called with player A, return value expected.
	call ReadPlayerA		; Call function to read the data in of player A, return value expected.
	jmp CollisionPosition	; Go to check the position for collision.
ReadPlayerB2:				; Read the data in of player B, return value expected.
	call ReadPlayerB		; Call function to read the data in of player B, return value expected.
CollisionPosition:			; Function to check the position for collision.
	mov ax, di				; Store the y coordinate in a register.
	mov bx, 320				; Store the value 320 to a register.
	mul	bx					; Get the row in the console window. (Y * 320)
	add	ax, si				; Add the x coordinate value to line value to get the position.
	mov di, ax				; Overwrite the y coordinate with the position.
	mov al, es:[di]			; Gets the color of the pixel from the video memory.
	cmp al, 0				; Is the pixel color black?
	jnz CollisionReturn		; Go to set return value to 1 if pixel was not black.
	mov ax, 0				; Set 0 as a return value.
	ret						; Return to the calling line.
CollisionReturn:			; Function to set return value to 1.
	mov ax, 1				; Set 1 as a return value.
	ret						; Return to the calling line.
CheckAPosition:				; Checks the position of player A if it's inside of the map. return value: (ax=0, ax=1)
	call ReadPlayerA		; Call function to read the data in of player A, return value expected.
	mov ax, di				; Store the y coordinate in another register.
	cmp ax, 1				; Is the y coordinate at the edge of the map?
	jz IncreaseALife		; Go to increase the life of player A if the y coordinate is at the edge of the map.
	dec ax					; Decrease the value of the register.
	mov di, ax				; Set the y coordinate's value as a parameter.
	cmp cl, 1				; Is the direction's value 1?
	jz ValidateA			; Go to validate the position of player A.
	call ReadPlayerA		; Call function to read the data in of player A, return value expected.
	mov ax, si				; Store the x coordinate in another register.
	cmp ax, 319				; Is the x coordinate at the edge of the map?
	jz IncreaseALife		; Go to increase the life of player A if the x coordinate is at the edge of the map.
	inc ax					; Increase the value of the register.
	mov si, ax				; Set the x coordinate's value as a parameter.
	cmp cl, 2				; Is the direction's value 2?
	jz ValidateA			; Go to validate the position of player A.
	call ReadPlayerA		; Call function to read the data in of player A, return value expected.
	mov ax, di				; Store the y coordinate in another register.
	cmp ax, 199				; Is the y coordinate at the edge of the map?
	jz IncreaseALife		; Go to increase the life of player A if the y coordinate is at the edge of the map.
	inc ax					; Increase the value of the register.
	mov di, ax				; Set the y coordinate's value as a parameter.
	cmp cl, 3				; Is the direction's value 3?
	jz ValidateA			; Go to validate the position of player A.
	call ReadPlayerA		; Call function to read the data in of player A, return value expected.
	mov ax, si				; Store the x coordinate in another register.
	cmp ax, 1				; Is the x coordinate at the edge of the map?
	jz IncreaseALife		; Go to increase the life of player A if the x coordinate is at the edge of the map.
	dec ax					; Decrease the value of the register.
	mov si, ax				; Set the x coordinate's value as a parameter.
	cmp cl, 4				; Is the direction's value 4?
	jz ValidateA			; Go to validate the position of player A.
ValidateA:					; Validate the position of player A. (si->x; di->y; cl->direction; ch->color), no return value.
	call UpdatePlayerA		; Call function to overwrite the saved data of player A with the parameter, no return value.
	mov ax, 1				; Set 1 as a parameter to call the function with player A.
	call CollisionHandler	; Call function to check for collision, return value expected.
	cmp ax, 1				; Was there a collision?
	jz IncreaseALife		; Increase the life of player A if there was a collision.
	ret						; Return to the calling line.
IncreaseALife:				; Function to increase the life of player A, no return value.
	mov di, offset playerA	; Set the address of the player A data to the register.
	mov al, 2				; Set 2 to a register.
	mov [di + 6], al		; Set 2 as the player's life.
	ret						; Return to the calling line.
CheckBPosition:				; Checks the position of player B if it's inside of the map. return value: (ax=0, ax=1)
	call ReadPlayerB		; Call function to read the data in of player B, return value expected.
	mov ax, di				; Store the y coordinate in another register.
	cmp ax, 1				; Is the y coordinate at the edge of the map?
	jz IncreaseBLife		; Go to increase the life of player B if the y coordinate is at the edge of the map.
	dec ax					; Decrease the value of the register.
	mov di, ax				; Overwrite the y coordinate's value.
	cmp cl, 1				; Is the direction's value 1?
	jz ValidateB			; Go to validate the position of player B.
	call ReadPlayerB		; Call function to read the data in of player B, return value expected.
	mov ax, si				; Store the x coordinate in another register.
	cmp ax, 319				; Is the x coordinate at the edge of the map?
	jz IncreaseBLife		; Go to increase the life of player B if the x coordinate is at the edge of the map.
	inc ax					; Increase the value of the register.
	mov si, ax				; Overwrite the x coordinate's value.
	cmp cl, 2				; Is the direction's value 2?
	jz ValidateB			; Go to validate the position of player B.
	call ReadPlayerB		; Call function to read the data in of player B, return value expected.
	mov ax, di				; Store the y coordinate in another register.
	cmp ax, 199				; Is the y coordinate at the edge of the map?
	jz IncreaseBLife		; Go to increase the life of player B if the y coordinate is at the edge of the map.
	inc ax					; Increase the value of the register.
	mov di, ax				; Overwrite the y coordinate's value.
	cmp cl, 3				; Is the direction's value 3?
	jz ValidateB			; Go to validate the position of player B.
	call ReadPlayerB		; Call function to read the data in of player B, return value expected.
	mov ax, si				; Store the x coordinate in another register.
	cmp ax, 1				; Is the x coordinate at the edge of the map?
	jz IncreaseBLife		; Go to increase the life of player B if the x coordinate is at the edge of the map.
	dec ax					; Decrease the value of the register.
	mov si, ax				; Overwrite the x coordinate's value.
	cmp cl, 4				; Is the direction's value 4?
	jz ValidateB			; Go to validate the position of player B.
ValidateB:					; Validate the position of player B. (si->x; di->y; cl->direction; ch->color), no return value.
	call UpdatePlayerB		; Call function to overwrite the saved data of player B with the parameter, no return value.
	mov ax, 2				; Set 2 as a parameter to call the function with player B.
	call CollisionHandler	; Call function to check for collision, return value expected.
	cmp ax, 1				; Was there a collision?
	jz IncreaseBLife		; Increase the life of player B if there was a collision.
	ret						; Return to the calling line.
IncreaseBLife:				; Function to increase the life of player B, no return value.
	mov di, offset playerB	; Set the address of the player B data to the register.
	mov al, 2				; Set 2 to a register.
	mov [di + 6], al		; Set 2 as the player's life.
	ret						; Return to the calling line.
EndMatch:					; Handles the end of the match.
	call EmptyStack			; Call the function to empty out the stack.
	call ConsoleMode		; Call the function to set the display to console mode.
	mov di, offset playerB	; Set the address of the player B data to the register.
	mov al, [di + 6]		; Read the life value of the player.
	cmp al, 2				; Compare the life of player B to 2.
	jz AWonResult			; If the life of player B is 2, then go to player A won result.
	mov dx, offset BWon		; Set the address of the player B won to the register.
	mov ah, 09h				; Set the DOS function to display a string.
	int 21h					; Call DOS service.
	jmp WaitForKey			; Go to wait for key input.
AWonResult:					; The result when player A won the match.
	mov dx, offset AWon		; Set the address of the player A won to the register.
	mov ah, 09h				; Set the DOS function to display a string.
	int 21h					; Call DOS service.
WaitForKey:					; Waits for a key input.
	xor	ax, ax				; Read keyboard character function. (ah = keyboard scan code, al = ASCII character code)
	int	16h					; Call BIOS keyboard service.
	jmp AskNewMatch			; Go to exit the application.
AskNewMatch:				; Ask the players if they want another match.
	mov dx, offset NewMatch	; Set the address of the question string terminated with a '$' to the register.
	mov ah, 09h				; Set DOS function to display a string.
	int 21h					; Call DOS service.
ReadInput4:					; Reads the input key.
	mov ah, 01h				; Read keyboard input status function. (ah = keyboard scan code, al = ASCII character code)
	int 16h					; Call BIOS keyboard service.
	jnz Buttons2			; Handle buttons if any was pushed.
	jmp ReadInput4			; Go to reading the input key.
Buttons2:					; Handle the pushed buttons and continue the process accordingly.
	mov ah, 00h				; Read keyboard character function. (ah = keyboard scan code, al = ASCII character code)
	int 16h					; Call BIOS keyboard service.
	cmp al, "y"				; Was the read input the y key?
	jz VgaMode				; Go to setting the display to vga mode.
	cmp al, "Y"				; Was the read input the Y key?
	jz VgaMode				; Go to setting the display to vga mode.
	cmp al, "n"				; Was the read input the n key?
	jz ExitApplication		; Go to exit the application.
	cmp al, "N"				; Was the read input the N key?
	jz ExitApplication		; Go to exit the application.
	jmp ReadInput4			; Go to input key reading.
ConsoleMode:				; Function to the display mode to console.
	mov ax, 03h				; Set BIOS service to console mode.
	int 10h					; Call BIOS service.
	ret						; Return to the calling line.
EmptyStack:					; Function to empty out the stack.
	pop dx					; Empty out the stack.
	ret						; Return to the calling line.
ExitApplication:			; Exit the application.
	mov ax, 4c00h			; Set DOS service to exit the application.
	int 21h					; Call DOS service.
; player|x coordinate|y coordinate|direction|color|life|
; player|2 * 8bit    |2 * 8bit    |8bit     |8bit |8bit|
playerA: db "       "
playerB: db "       "
AWon: db "Player A won the match.$"
BWon: db "Player B won the match.$"
NewMatch: db "Would you like another match? (y/n)$"

Code	Ends

Data	Segment

Data	Ends

Stack	Segment

Stack	Ends
	End Start
