
CREATE TABLE Rol (
    ID INT PRIMARY KEY,
    Descripcion VARCHAR(50)
);


CREATE TABLE Estudiante (
    ID_No_Control INT PRIMARY KEY,
    Nombre VARCHAR(100),
    ApellidoP VARCHAR(100),
    ApellidoM VARCHAR(100),
    Correo VARCHAR(100),
    Telefono BIGINT,
    Contrasena VARCHAR(100),
    Carrera VARCHAR(100),
    Semestre INT,
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(ID)
);


CREATE TABLE Docente (
    ID_RFC VARCHAR(13) PRIMARY KEY,
    Nombre VARCHAR(100),
    ApellidoP VARCHAR(100),
    ApellidoM VARCHAR(100),
    Correo VARCHAR(100),
    Telefono BIGINT,
    Contrasena VARCHAR(100),
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(ID)
);

CREATE TABLE Admin (
    ID_Admin INT PRIMARY KEY,
    Usuario VARCHAR(100),
    Contrasena VARCHAR(100),
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(ID)
);

CREATE TABLE Chef (
    ID_Chef INT PRIMARY KEY,
    Nombre VARCHAR(100),
    ApellidoP VARCHAR(100),
    ApellidoM VARCHAR(100),
    Contrasena VARCHAR(100),
    PK_ROL INT,
    FOREIGN KEY (PK_ROL) REFERENCES Rol(ID)
);


CREATE TABLE Menu (
    ID_Menu INT PRIMARY KEY,
    Platillos TEXT,
    Postres TEXT,
    Bebida TEXT
);


CREATE TABLE Platillo (
    ID_platillo INT PRIMARY KEY,
    Nombre VARCHAR(100),
    Descripcion TEXT,
    Precio DECIMAL(10,2),
    Cantidad INT,
    PK_Menu INT,
    FOREIGN KEY (PK_Menu) REFERENCES Menu(ID_Menu)
);


CREATE TABLE Postre (
    ID_postre INT PRIMARY KEY,
    Tipos VARCHAR(100),
    Precio DECIMAL(10,2),
    Nombre_postre VARCHAR(100),
    Cantidad INT,
    PK_Menu INT,
    FOREIGN KEY (PK_Menu) REFERENCES Menu(ID_Menu)
);


CREATE TABLE Bebidas (
    ID_bebida INT PRIMARY KEY,
    Tipo_bebida VARCHAR(100),
    CantidadMililitros INT,
    Precio DECIMAL(10,2),
    PK_Menu INT,
    FOREIGN KEY (PK_Menu) REFERENCES Menu(ID_Menu)
);

-
CREATE TABLE Orden (
    ID_Orden INT PRIMARY KEY,
    Fecha DATE,
    Hora TIME,
    Platillo TEXT,
    Bebidas TEXT,
    Postre TEXT,
    Cantidad INT,
    Precio DECIMAL(10,2),
    Total DECIMAL(10,2),
    Comentarios TEXT,
    status VARCHAR(50),
    PK_Docente VARCHAR(13),
    PK_Estudiante INT,
    FOREIGN KEY (PK_Docente) REFERENCES Docente(ID_RFC),
    FOREIGN KEY (PK_Estudiante) REFERENCES Estudiante(ID_No_Control)
);


CREATE TABLE ReporteDia (
    ID_Reporte INT PRIMARY KEY,
    Fecha DATE,
    Total DECIMAL(10,2),
    Platillo TEXT,
    Bebida TEXT,
    Postre TEXT,
    Cantidad INT,
    PK_Orden INT,
    FOREIGN KEY (PK_Orden) REFERENCES Orden(ID_Orden)
);


CREATE TABLE ReporteGeneral (
    ID_Reporte INT PRIMARY KEY,
    Fecha DATE,
    Tipo_Reporte VARCHAR(100),
    Total DECIMAL(10,2),
    Total_Platillo DECIMAL(10,2),
    Cantidad INT,
    PK_ReporteDia INT,
    FOREIGN KEY (PK_ReporteDia) REFERENCES ReporteDia(ID_Reporte)
);


INSERT INTO Rol (ID, Descripcion) VALUES (1, 'Admin');
INSERT INTO Rol (ID, Descripcion) VALUES (2, 'Chef');
INSERT INTO Rol (ID, Descripcion) VALUES (3, 'Estudiante');
INSERT INTO Rol (ID, Descripcion) VALUES (4, 'Docente');
