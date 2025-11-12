:- dynamic jugador/1.
:- dynamic inventario/1.
:- dynamic usado/1.
:- dynamic lugar_bloqueado/1.
:- dynamic lugares/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hechos del juego %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Lugares 
lugar(bosque, "Bosque sombrío con árboles milenarios."). 
lugar(puente, "Un viejo puente de madera."). 
lugar(cueva, "Cueva donde habita el dragón."). 
lugar(templo, "Templo abandonado con inscripciones antiguas."). 
% lugar(ejemplo, "Sin descripcion").
% Conexiones 
conectado(bosque, puente). 
conectado(puente, cueva). 
conectado(cueva, templo). 
% conectado(cueva, ejemplo).
% Objetos 
objeto(llave, templo). 
objeto(espada, bosque). 
objeto(escudo, puente). 
% Requisitos 
requiere(llave, cueva). 
requiere(espada, puente). 
requiereVisita(cueva, bosque). 
% Estado inicial 
jugador(bosque). 
inventario([]). 
% Tesoro 
tesoro(templo, escudo).
% tesoro(ejemplo, armadura).
usado([]).
lugares([]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicados del juego %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Instansce map of the game by a Generic Tree Structure

% mapa(_, []).
% mapa(Punto, SubCaminos) :-
%    conectado(Punto, Siguiente),
%    mapa(Siguiente, X).

construir_mapa(Punto, mapa(Punto, SubCaminos)) :-
    findall(Subcamino, (
        conectado(Punto, Siguiente),
        construir_mapa(Siguiente, Subcamino)
    ), SubCaminos).

% Show to the player a conection between places

mostrar_lugar :-
    lugar(Nombre, Descripcion),
    write('Lugar: '), write(Nombre), nl,
    write('Descripcion: '), write(Descripcion), nl.

% Instance blocked places with requirements 

% lugar_bloqueado(Lista) :-
%     findall(Lugar, requiere(_, Lugar), Lista).

% lugar_bloqueado(Lugar) :- requiere(Objeto, Lugar), \+ usado(Usados), !. 
% lugar_bloqueado(Lugar) :- requiere(Objeto, Lugar) , usado(Usados), \+ member(Objeto, Usados).

lugar_bloqueado(Lista) :-
    findall(Lugar, (requiere(Objeto, Lugar), usado(Usados), \+ member(Objeto, Usados)), Lista).

% Eliminates a element from a List

eliminar(_, [], []).
eliminar(X, [X|L], L).
eliminar(X, [Y|L], [Y|R]) :- X \= Y, eliminar(X, L, R).

desbloquear(Lugar) :-
    requiere(Objeto, Lugar),
    usado(Usados),
    member(Objeto, Usados),
    write('El camino hacia '), write(Lugar), write(' ya esta desbloqueado'), nl.

desbloquear(Lugar) :-
    requiere(Objeto, Lugar),
    \+ (usado(Lista), member(Objeto, Lista)),
    retract(usado(Lista)),
    assertz(usado([Objeto|Lista])),
    write('Has desbloqueado'), write(Lugar), nl.

% conexion(Lugar1, Lugar2) :- lugar(Lugar1,_), lugar(Lugar2,_), conectado(Lugar2, Lugar1).
% conexion(Lugar1, Lugar2) :- conectado(Lugar1, Lugar3), conexion(Lugar3, Lugar2).

% Instance requirement to enter a place using an object

comprobar_requisito(Objeto, IngresoLugar) :-
    requiere(Objeto, IngresoLugar), !,
    write(''), nl. 

comprobar_requisito(_, _) :- 
    write('No puedes usar este objeto para ingresar'), nl, fail.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicados principales del juego %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Tomar objeto

tomar(Objeto) :-
    objeto(Objeto, _),
    inventario(Inventario),
    \+ member(Objeto, Inventario),
    write('Has tomado el objeto en el suelo '), write(Objeto), write(', seria dificil avanzar sin el...'), nl,
    retract(inventario(Inventario)),
    assertz(inventario([Objeto|Inventario])).

% Usar objeto

usar(Objeto) :- 
    inventario(Inventario),
    member(Objeto, Inventario),
    jugador(Lugar),
    conectado(Lugar, Destino),
    requiere(Objeto, Destino), !,
    ( retract(usado(Usados)) ; Usados = [] ),
    assertz(usado([Objeto|Usados])),
    desbloquear(Destino),
    write('Has usado el objeto '), write(Objeto), nl,
    write('y has desbloqueado el lugar '), write(Destino), nl.

usar(Objeto) :-
    (write('Usas el objeto '), write(Objeto), write(', pero no pasa nada...'), nl, fail).


% Verificar si el jugador puede ir a un lugar

puedo_ir(Hacia):-
    jugador(Lugar),
    conectado(Lugar, Hacia),
    (requiere(Objeto, Hacia) ->
        (inventario(Inventario),
        member(Objeto, Inventario) -> 
            write('Puedes avanzar a '), write(Hacia), nl
            ; (write('No puedes avanzar a '), write(Hacia), write(', te falta el objeto '), write(Objeto), nl, fail)
        )
    ; write('Puedes avanzar a '), write(Hacia), nl
    ).


% Mover jugador

mover(Lugar) :-
    jugador(Actual),
    (conectado(Actual, Lugar) -> 
        true 
        ; write('No puedes avanza hacia ese lugar desde aqui.'), nl, fail
    ),
    lugar_bloqueado(Lista), 
    ( member(Lugar, Lista) ->
        write('Parece que el lugar frente a ti esta bloqueado'), 
        write(' tal vez haya algo alrededor que te ayude a desbloquearlo'), nl, fail
        ; retractall(jugador(_)), assertz(jugador(Lugar)), write('Avanzas hacia '), write(Lugar), nl,
        retract(lugares(Lugares)),
        assertz(lugares([Lugar|Lugares]))
    ).

% Indicar lugar del objeto

donde_esta(Objeto):- 
    objeto(Objeto, Lugar),
    write('El objeto '), write(Objeto), write(' esta ubicado en '), write(Lugar), nl.

donde_esta(Objeto) :-
    inventario(Inventario),
    member(Objeto, Inventario),
    write('El objeto esta en tu inventario'), nl.

donde_esta(Objeto) :-
    write('No parece que ese objeto este en algun lugar conocido...'), nl.

% Ver inventario

leer_([]).
leer_([CB|CL]) :-
    write('- '), write(CB), nl,
    leer_(CL).

que_tengo() :-
    inventario(Inventario),
    write('En tu inventario tienes:'), nl,
    leer_(Inventario).

% Ver lugares visitados.

lugar_visitado() :-
    Lugares(Lugares),
    write('Has visitado estos lugares:'), nl,
    leer_(Lugares).

% Encuentra la ruta logica entre dos lugares

ruta(mapa(Inicio,_), Inicio, [Inicio]).

ruta(mapa(Inicio, SubCamino), Fin, [Inicio|Camino]) :-
    member(Siguiente, SubCamino),
    ruta(Siguiente, Fin, Camino).

% Indica todas las rutas logicas para ganar el juego

como_gano() :-
    jugador(Inicio),
    tesoro(Fin, _),
    construir_mapa(Inicio, Mapa),
    rutas(Inicio, Fin, Rutas),
    write('Posibles rutas para ganar: '), nl, leer_(Rutas), nl.

rutas(Inicio, Fin, Rutas) :-
    findall(Camino, subRutas(Inicio, Fin, [Inicio], Camino), Rutas).

subRutas(Fin, Fin, Camino, Camino).

subRutas(Inicio, Fin, Visitados, Camino) :-
    conectado(Inicio, Siguiente),
    \+ member(Siguiente, Visitados),
    append(Visitados, [Siguiente], Visitados2),
    subRutas(Siguiente, Fin, Visitados2, Camino).


