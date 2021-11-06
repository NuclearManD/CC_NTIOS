--# Enigma Security Software v4.6 - Api ,simple/sample program
--# Made By Wojbie
--# http://pastebin.com/WYuNMxQx

--   Copyright (c) 2015-2021 Wojbie (wojbie@wojbie.net)
--   Redistribution and use in source and binary forms, with or without modification, are permitted (subject to the limitations in the disclaimer below) provided that the following conditions are met:
--   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
--   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
--   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
--   4. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
--   5. The origin of this software must not be misrepresented; you must not claim that you wrote the original software.
--   NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

--# This part defines functions that will be used in this api.

--# Table reversor
local function rev(A) local tRev,i,j={} for i,j in pairs(A) do tRev[j]=i end return tRev end

--# Table duplicator
local function copyT(A)
	if not A or type(A)~="table" then return A end
	local B={}
		for i,k in pairs(A) do
			if type(k)=="table" then B[i]=copyT(k) 
			else B[i]=k end
		end
	return B
end

--# Rotors
local rot = {
{95,96,63,85,3,89,19,62,23,30,11,29,75,83,67,25,36,41,91,14,9,61,54,44,94,33,26,69,18,8,15,76,43,5,16,66,72,92,52,46,45,24,39,68,12,55,80,77,2,17,78,81,6,60,32,59,10,65,4,34,42,50,70,64,93,47,21,57,37,49,13,28,48,35,27,56,88,31,58,1,40,71,82,22,74,20,86,38,84,79,90,87,53,7,73,51},
{95,96,66,2,49,67,43,20,61,76,51,50,35,82,13,17,1,91,3,85,16,27,63,23,33,87,39,81,30,59,42,70,78,9,72,7,37,54,89,44,36,31,57,64,41,45,83,21,38,65,25,90,48,18,40,6,74,22,62,46,88,77,32,34,12,84,68,29,69,75,73,4,24,94,56,15,19,79,58,53,92,55,14,26,47,80,52,10,60,71,5,86,28,93,11,8},
{95,96,51,69,50,34,28,17,43,42,1,75,4,25,85,32,87,58,63,73,19,36,16,64,47,26,71,76,78,3,93,13,61,46,70,49,68,45,39,81,40,62,7,88,5,38,92,48,12,83,82,24,18,9,8,90,55,29,44,35,14,6,52,72,10,60,21,79,11,80,27,91,31,30,33,53,66,89,77,22,57,41,2,15,94,20,86,56,23,37,59,65,67,84,74,54},
{76,30,55,90,91,83,22,48,74,64,77,40,71,57,92,51,66,85,56,41,1,17,18,93,36,27,16,43,50,75,21,70,38,31,84,58,82,45,53,52,78,96,12,34,3,11,68,6,46,9,94,67,61,44,37,47,35,63,69,4,25,81,2,65,32,62,7,29,33,14,28,19,72,24,60,54,39,95,23,73,79,20,59,87,10,88,13,86,42,5,49,26,8,89,80,15},
{13,89,7,80,58,3,1,65,92,81,30,8,96,48,43,47,79,61,51,4,88,29,78,27,94,22,16,45,74,72,70,95,36,59,39,60,75,12,64,77,10,49,26,17,11,46,9,6,76,85,19,2,66,5,73,62,41,87,54,71,28,21,14,15,23,44,69,82,24,20,90,42,57,33,50,34,93,31,83,84,18,37,53,91,56,38,63,40,52,86,25,68,32,35,67,55},
{70,10,14,8,48,88,63,12,37,91,71,20,50,65,87,78,79,46,39,75,29,9,53,36,13,21,24,19,44,81,49,58,22,61,42,96,66,64,56,27,86,47,89,84,59,74,32,30,16,6,72,33,95,57,80,69,34,5,85,94,41,90,60,2,23,67,35,76,77,52,68,11,7,51,73,26,62,25,15,17,45,43,82,1,92,83,18,93,28,3,55,4,40,38,31,54},
{9,60,38,64,85,91,63,1,53,81,18,94,35,55,16,57,19,27,47,71,11,17,50,84,31,6,34,88,25,43,46,33,21,5,89,48,37,2,75,87,59,52,76,70,69,23,45,80,40,56,14,73,62,32,30,92,82,78,61,72,44,54,12,68,29,7,65,24,96,8,74,79,95,26,20,4,41,51,90,42,22,39,3,36,67,15,58,49,10,13,28,66,93,86,77,83},
{82,16,57,49,4,20,61,93,47,90,28,3,35,81,84,24,69,94,19,32,21,79,33,68,38,64,76,26,72,31,30,13,39,70,92,18,5,10,25,11,14,71,46,45,78,41,88,15,53,56,51,74,89,8,83,9,86,87,50,2,73,95,34,40,29,43,60,12,96,58,42,23,52,6,1,55,36,7,17,66,77,67,80,59,63,44,37,85,48,75,62,22,91,65,54,27},
{79,64,53,47,28,39,63,43,26,9,5,19,69,29,12,84,11,15,18,46,60,56,27,33,24,17,74,85,34,95,51,88,72,13,16,4,77,49,59,71,25,22,70,30,14,42,8,52,92,41,87,55,83,6,67,57,38,61,54,35,81,45,1,23,48,3,80,90,96,75,32,76,36,37,86,89,78,40,62,58,66,10,73,7,44,65,82,94,50,91,20,21,93,2,68,31},
{24,88,80,16,37,30,6,19,7,22,3,75,81,90,46,18,21,1,4,9,59,72,23,91,11,86,54,49,69,50,66,5,51,41,71,74,17,38,20,67,96,84,85,14,76,53,36,70,89,47,94,2,13,25,39,78,92,42,28,95,31,82,56,26,87,65,44,55,34,45,35,68,33,77,8,32,57,40,93,79,61,64,62,52,63,83,73,27,12,60,15,58,48,10,43,29},
}

local al = {" ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/","0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?","@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_","`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","{","|","}","~","\n",} -- changed \000 to \n for experiment - should cause it to switch enters in coded file while leaving \r be. Add both \000 and \r?
local la = rev(al)
local alen = #al

--# Crypting helper functions
local function norm(A)	while A>alen do A=A-alen end while A<1 do A=A+alen end return A end
local function tick(t) t[7]=t[7]+1 if t[7]>alen then t[7]=1 t[8]=t[8]+1 end if t[8]>alen then t[8]=1 t[9]=t[9]+1 end if t[9]>alen then t[9]=1 end end

--# Validator functions.
--number validator

local function inRange(m,low,high)
	low = low or -math.huge
	high = high or math.huge
	return m >= low and m <= high
end

--table validator

local function valTable(t)
	local left={}
	local right={}

	for i,k in pairs(t) do
		left[i] = true
		right[k] = true
	end
		
	if #left ~= alen or #right ~= alen then return false end

	for i=1,alen do
		if not (left[i] and right[i]) then return false end
	end

	return true
end

--# Api Functions
--Main function - creates crypter
local function enigmaCrypter(tA,tB,tC,nA,nB,nC,bLock) --Create Crypter using tA,tB,tC rotors and set it to nA,nB,nC positions. If tA,tB,tC are numbers use provided rotors from table if they are tables use them as rotor.

	if type(tA) == "table" and not valTable(tA) or
	type(tA) == "table" and not valTable(tA) or
	type(tA) == "table" and not valTable(tA) then
	return false,"One or more rotor tables are invalid." end

	if type(tA) == "number" and not rot[tA] or
	type(tB) == "number" and not rot[tB] or
	type(tC) == "number" and not rot[tC] then
	return false,"One or more rotor outside of range." end
	
	tA,tB,tC= rot[tA] or tA , rot[tB] or tB , rot[tC] or tC
	
	if type(tA) ~= "table" or
	type(tA) ~= "table" or
	type(tA) ~= "table" then
	return false,"One or more rotor selectors is not valid variable." end
	
	if type(nA) ~= "number" or type(nA) == "number" and not inRange(nA,1,alen) or
		type(nB) ~= "number" or type(nB) == "number" and not inRange(nB,1,alen) or
		type(nC) ~= "number" or type(nB) == "number" and not inRange(nC,1,alen) then
		return false,"One or more initial positions are invalid. Positions need to be in range of 1-"..alen.."."
	end
	
	--All is valid by this point.
	
	local t = {copyT(tA),copyT(tB),copyT(tC),rev(tC),rev(tB),rev(tA),norm(nA),norm(nB),norm(nC)}

	--# Metatable for crypting with table.
	local metaCrypter = {
		["__newindex"]=function(sT,k,v) --Don't let any changes to happen.
		end,
		["__call"]=function(sT,k) --Call crypter like function? Crypting	time!
			if type(k)=="string" then 
				return string.gsub(k,".", function(c)
					--crypt one char here
					if la[c] then
						local L=la[c]
						L = norm(L+t[1][ t[7] ]) 
						L = norm(L+t[2][ t[8] ])
						L = norm(L+t[3][ t[9] ])
						L = alen - L
						L = norm(L-t[4][ t[9] ])
						L = norm(L-t[5][ t[8] ])
						L = norm(L-t[6][ t[7] ])
						tick(t)
						return al[L]
					else
						return false --keep orginal in the string unchanged
					end
				end)
			else
				return nil --Give back nothing
			end
		end,
		["__metatable"]={},--Protection from accidental removal of matatable.
	}
	
	local locked = bLock and true
	local blockCopy = function() locked=true end
	local copy = function(bFlag) if not locked then return enigmaCrypter(t[1],t[2],t[3],t[7],t[8],t[9],bFlag) else return false,"Copying disabled" end end
	return setmetatable({copy=copy,clone=copy,blockCopy=blockCopy},metaCrypter)
end

--# Example of crypter set to rotors 1,2,3 and to position 1,1,1
local Example = enigmaCrypter(1,2,3,1,1,1)

--# end of Api definition

if shell or multishell then --program version

	local tArgs={...}

	if #tArgs==0 then
		print("You have run this api instead of loading it. You can use it as single file crypter by using 'enigma <absotue path>'. Selected file will be overwritten with encrypred version. This is still an example program and enigma was made as api for you to use. Use os.loadApi on this file to load it.")
		return
	end

	if not fs.exists(tArgs[1]) or fs.isDir(tArgs[1]) or fs.isReadOnly(tArgs[1]) then
		print("File "..tArgs[1].." don't exist, is a directory or is in readonly folder. Can't Enigma that!")
		return
	end

	--# Basic Gui stuff

	local A,B,C,a,b,c

	--#  Basic Pass Screen
	local function Bwreact()
		term.clear()
		term.setCursorPos(1,1)
		print("Select rotors [0-9]")
		while not A or A<0 or A>9 do print("rotor 1:") A=tonumber(read("*")) end
		while not B or B<0 or B>9 do print("rotor 2:") B=tonumber(read("*")) end
		while not C or C<0 or C>9 do print("rotor 3:") C=tonumber(read("*")) end
		A,B,C=A+1,B+1,C+1
		term.clear()
		term.setCursorPos(1,1)
		print("Enter rotors Positons [0-99]")
		while not a or a<0 or a>99 do print("rotor 1 Positons:") a=tonumber(read("*")) end
		while not b or b<0 or b>99 do print("rotor 2 Positons:") b=tonumber(read("*")) end
		while not c or c<0 or c>99 do print("rotor 3 Positons:") c=tonumber(read("*")) end
		term.clear()
		term.setCursorPos(1,1)
	end

	Bwreact()

	local process = enigmaCrypter(A,B,C,a,b,c)

	--# Working example code

	local input=fs.open(tArgs[1],"r")
	local data=input.readAll()
	input.close()
	data=process(data)
	local output=fs.open(tArgs[1],"w")
	output.write(data)
	output.close()

	return

end

--# Api version - define crypter

crypter = enigmaCrypter
return enigmaCrypter

--A coin has two sides, and one is always the winner. Flip accordingly.