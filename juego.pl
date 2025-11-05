% Instance conection between places

lugar(Nombre, Descripcion) :-
    write('Lugar: '), write(Nombre), nl,
    write('Descripcion: '), write(Descripcion), nl.

% Hacer un predicado que guarde en una lista los caminos bloqueados
conexion(Lugar1, Lugar2) :- conectado(Lugar2, Lugar1).
conexion(Lugar1, Lugar2) :- conectado(Lugar1, Lugar3), conexion(Lugar3, Lugar2).

% Instance conection between objects and places, a place must exist before a object

objeto(Objeto, LugarEsta) :- lugar(LugarEsta, _), write('El objeto '), write(Objeto), write(' Esta ubicado en '), write(LugarEsta), nl.

% :- objeto(Objeto, LugarEsta), conexion(LugarEsta, IngresoLugar), write('Para obtener el objeto '), write(Objeto), write(' necesitas ingresar a '), write(IngresoLugar), nl.

% Instance requirement to enter a place using an object

comprobar_requisito(Objeto, IngresoLugar) :-
    requiere(Objeto, IngresoLugar), !,
    write(''), nl. 

comprobar_requisito(_, _) :- 
    write('No puedes usar este objeto para ingresar'), nl, fail.

requiereVisita(LugarDestino, LugarVisitado) :- conexion(LugarDestino, LugarVisitado).

jugador(Lugar) :- lugar(Lugar, _).

inventario([]).
tomar(Objeto) :-
    objeto(Objeto, LugarEsta),
    inventario(Inventario),
    \+ member(Objeto, Inventario),
    % write('Has tomado el objeto en el suelo '), write(Objeto), write('seria dificil avanzar sin el...'), nl,
    retract(inventario(Inventario)),
    assert(inventario([Objeto|Inventario])).

usado([]).
usar(Objeto) :- 
    inventario(Inventario),
    member(Objeto, Inventario),
    write('Has usado el objeto '), write(Objeto), nl,
    retract(inventario(Inventario)),
    assert(usado([Objeto|Inventario])).  
    
