--Creating tables and adding data
CREATE TABLE Fields(
	FieldId SERIAL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL
);
INSERT INTO Fields (Name) VALUES
('Programiranje'),
('Dizajn'),
('Multimedija'),
('Marketing');	

SELECT * FROM Fields

CREATE TABLE Phases(
	PhaseId SERIAL PRIMARY KEY,
	Name VARCHAR(10) CHECK(Name IN('U pripremi','U tijeku', 'Zavrsen')) NOT NULL
);

INSERT INTO Phases (Name) VALUES
('U pripremi'),
('U tijeku'),
('Zavrsen');

SELECT * FROM Phases

CREATE TABLE Members(
	MemberId SERIAL PRIMARY KEY,
	Name VARCHAR(20) NOT NULL,
	Surname VARCHAR(20) NOT NULL,
	Oib VARCHAR(11) UNIQUE NOT NULL CHECK(LENGTH(Oib) = 11),
	Birth TIMESTAMP NOT NULL,
	Gender VARCHAR(1) CHECK (Gender IN ('M', 'F')) NOT NULL,
	Place VARCHAR(20) NOT NULL	
);

INSERT INTO Members (Name, Surname, Oib, Birth, Gender, Place) VALUES
('Ante', 'Antic', '30000000600', '2000-1-1', 'M', 'Split'),
('Mate', 'Matic', '50000000001', '2000-1-2', 'M', 'Solin'),
('Ivan', 'Ivic', '80000000002', '2003-1-1', 'M', 'Omis'),
('Luka', 'Lukic', '90000000003', '1999-6-8', 'M', 'Dicmo'),
('Ana', 'Anic', '70000006500', '2000-1-1', 'F', 'Split'),
('Lana', 'Lanic', '50000000320', '1998-3-1', 'F', 'Trogir'),
('Petra', 'Petric', '20042000000', '1998-3-1', 'F', 'Split'),
('Sara', 'Saric', '04000078000', '2001-1-6', 'F', 'Sinj'),
('Iva', 'Ivic', '00500002220', '2004-1-1', 'F', 'Trilj');

SELECT * FROM Members


CREATE TABLE Internships(
	InternshipId SERIAL PRIMARY KEY,
	StartDate TIMESTAMP NOT NULL,
	EndDate TIMESTAMP NOT NULL,
	PhaseId INT REFERENCES Phases(PhaseId) NOT NULL,
	ProjectLeaderId INT REFERENCES Members(MemberId) NOT NULL
);

INSERT INTO Internships(StartDate,EndDAte,PhaseId,ProjectLEaderId) VALUES
('2021-11-6', '2022-5-4', 3,3),
('2022-11-3', '2023-6-1', 2,4),
('2023-10-30', '2024-5-25', 1,5);

SELECT * FROM Internships


CREATE TABLE InternshipsFields(
	InternshipId INT REFERENCES Internships(InternshipId),
	FieldId INT REFERENCES Fields(FieldId),
	PRIMARY KEY (InternshipId, FieldId),	
	LeaderId INT REFERENCES Members(MemberId) NOT NULL
);
CREATE TABLE Interns(
	InternId SERIAL PRIMARY KEY,
	Name VARCHAR(30) NOT NULL,
	Surname VARCHAR(30) NOT NULL,
	Oib VARCHAR(11) UNIQUE NOT NULL CHECK(LENGTH(Oib) = 11),
	Birth TIMESTAMP NOT NULL,
	Gender VARCHAR(1) CHECK(Gender IN('M','F')) NOT NULL,
	Place VARCHAR (30) NOT NULL
	CONSTRAINT InternOlderThan16 CHECK((CURRENT_TIMESTAMP - Birth) >= INTERVAL '16 year'),
	CONSTRAINT InternYoungerThan24 CHECK((CURRENT_TIMESTAMP - Birth) <= INTERVAL '24 year')
);
INSERT INTO Interns(Name, Surname, Oib, Birth, Gender, Place) VALUES
('Petar', 'Petic', '30040000600', '2000-1-1', 'M', 'Split'),
('Luka', 'Lukic', '50000000001', '2000-1-2', 'M', 'Solin'),
('Ivan', 'Ivic', '80000000042', '2003-1-1', 'M', 'Dugopolje'),
('Luka', 'Lukic', '90004000003', '2001-6-8', 'M', 'Dicmo'),
('Ivana', 'Ivanic', '70000036500', '2000-1-1', 'F', 'Knin'),
('Luca', 'Lucic', '50000005320', '2003-3-1', 'F', 'Trogir'),
('Petra', 'Petric', '20042004000', '2002-8-1', 'F', 'Split'),
('Sara', 'Saric', '04000078000', '2001-1-6', 'F', 'Kastela'),
('Iva', 'Ivic', '00500072220', '2002-1-1', 'F', 'Trilj');

SELECT * FROM Interns

CREATE TABLE AllInOne(
	MainId SERIAL PRIMARY KEY,
	Status VARCHAR (30) CHECK (Status IN ('pripravnik', 'izbacen', 'zavrsen internship')),
	InternId INT REFERENCES Interns(InternId),
	FieldId INT REFERENCES Fields(FieldId),
	InternshipId INT REFERENCES Internships(InternshipId)
);

INSERT INTO AllInOne (Status,InternId, FieldId, InternshipId ) VALUES
('pripravnik',7, 1 ,1),
('izbacen',8, 1,1),
('pripravnik',9, 2, 2),
('izbacen',10, 2, 2),
('izbacen',11, 3, 1),
('pripravnik',12,2,3);

SELECT * FROM AllInOne





CREATE TABLE Homeworks(
	HomeworkId SERIAL PRIMARY KEY,
	InternId INT REFERENCES Interns(InternId)  NOT NULL,
	FieldId INT REFERENCES Fields(FieldId)  NOT NULL,
	Grade INT CHECK(Grade >= 1 AND Grade<=5)  NOT NULL
);

INSERT INTO Homeworks(InternId, FieldId, Grade) VALUES
(7,1,2),
(7,1,3),
(8,1,5),
(8,1,2),
(8,1,1),
(9,2,4),
(9,2,1),
(10,2,2),
(10,2,1),
(11,3,5),
(11,3,5),
(12,2,4);



	
--●	ispišite ime i prezime članova koji žive izvan Splita
SELECT Name, Surname FROM Members
	WHERE Place NOT LIKE 'Split'

--●	ispišite datum početka i kraja svakog Internshipa, sortiranih po datumu početka od novijeg prema starom
SELECT StartDate,EndDate From Internships ORDER BY StartDate DESC
	
--●	ispišite ime i prezime svih interna 2021./2022.
SELECT Name, Surname FROM Interns i
	WHERE (SELECT COUNT(*) FROM AllInOne WHERE i.InternId=InternId AND (SELECT COUNT(*) FROM Internships WHERE AllInOne.InternshipId = InternshipId AND date_part('year', StartDate) = 2021) > 0) > 0
		   
--●	ispišite broj pripravnica na ovogodišnjem dev Internshipu
SELECT COUNT (*)FROM Interns i
	WHERE (i.Gender = 'F' AND (SELECT COUNT (*) FROM AllInOne WHERE i.InternId = InternId AND (SELECT COUNT (*) FROM Internships WHERE AllInOne.InternshipId = InternshipId AND (CURRENT_TIMESTAMP BETWEEN StartDate AND EndDate))>0) > 0)
			
--●	ispišite broj izbačenih marketingaša 
SELECT COUNT (*) FROM AllInOne
	WHERE (Status = 'izbacen' AND  (SELECT COUNT(*) FROM Fields WHERE AllInOne.FieldId = FieldId AND Name = 'Marketing') > 0)

--●	svim članovima čije prezime završava na -in promijenite mjesto stanovanja u Moskvu
UPDATE Members	
	SET Place = 'Moskva'
	WHERE Surname LIKE '%in';
	
SELECT * FROM Members


--●	izbrišite sve članove starije od 25 godina
DELETE FROM Members
	WHERE (CURRENT_TIMESTAMP - Birth) >= INTERVAL '25 year'

--●	izbacite sve pripravnike s prosjekom ocjena manjim od 2.4 na tom području
UPDATE AllInOne
	SET Status = 'izbacen'
	WHERE (SELECT AVG(Grade) FROM Homeworks h WHERE AllInOne.InternId = h.InternId AND AllInOne.FieldId = h.FieldId GROUP BY h.Internid,h.FieldId) < 2.4;
 
			