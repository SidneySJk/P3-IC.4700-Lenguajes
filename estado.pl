:- module(juego, [lugar/1, conectado/2, objeto/2, requiere/2, requiereVisita/2, jugador/1, inventario/1, tesoro/2]).

% Lugares 
lugar(bosque, "Bosque sombrío con árboles milenarios."). 
lugar(puente, "Un viejo puente de madera."). 
lugar(cueva, "Cueva donde habita el dragón."). 
lugar(templo, "Templo abandonado con inscripciones antiguas."). 
% Conexiones 
conectado(bosque, puente). 
conectado(puente, cueva). 
conectado(bosque, templo). 
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