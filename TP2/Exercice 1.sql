-- 1) Département avec le budget le plus élevé
SELECT dept_name
FROM department
WHERE budget = (SELECT MAX(budget) FROM department);


-- 2) Enseignants gagnant plus que le salaire moyen
SELECT name, salary
FROM instructor
WHERE salary > (SELECT AVG(salary) FROM instructor);


-- 3) Étudiants ayant suivi plus de 2 cours avec un enseignant (avec HAVING)
SELECT i.name AS enseignant,
       s.name AS etudiant,
       COUNT(*) AS nb_cours
FROM instructor i
JOIN teaches te ON i.ID = te.ID
JOIN takes ta
  ON te.course_id = ta.course_id
 AND te.sec_id    = ta.sec_id
 AND te.semester  = ta.semester
 AND te.year      = ta.year
JOIN student s ON s.ID = ta.ID
GROUP BY i.name, s.name
HAVING COUNT(*) > 2;


-- 4) Même question sans HAVING
SELECT *
FROM (
    SELECT i.name AS enseignant,
           s.name AS etudiant,
           COUNT(*) AS nb_cours
    FROM instructor i
    JOIN teaches te ON i.ID = te.ID
    JOIN takes ta
      ON te.course_id = ta.course_id
     AND te.sec_id    = ta.sec_id
     AND te.semester  = ta.semester
     AND te.year      = ta.year
    JOIN student s ON s.ID = ta.ID
    GROUP BY i.name, s.name
) t
WHERE nb_cours > 2;


-- 5) Étudiants n’ayant pas suivi de cours avant 2010
SELECT s.ID, s.name
FROM student s
WHERE s.ID NOT IN (
    SELECT DISTINCT ID
    FROM takes
    WHERE year < 2010
);


-- 6) Enseignants dont le nom commence par E
SELECT *
FROM instructor
WHERE name LIKE 'E%';


-- 7) Enseignants avec le 4ème salaire le plus élevé
SELECT name, salary
FROM instructor
WHERE salary = (
    SELECT MIN(salary)
    FROM (
        SELECT DISTINCT salary
        FROM instructor
        ORDER BY salary DESC
        FETCH FIRST 4 ROWS ONLY
    )
);


-- 8) Les 3 salaires les plus faibles (ordre décroissant)
SELECT name, salary
FROM (
    SELECT name, salary
    FROM instructor
    ORDER BY salary ASC
    FETCH FIRST 3 ROWS ONLY
)
ORDER BY salary DESC;


-- 9) Étudiants ayant suivi un cours en automne 2009 (avec IN)
SELECT name
FROM student
WHERE ID IN (
    SELECT ID
    FROM takes
    WHERE semester = 'Fall' AND year = 2009
);


-- 10) Étudiants ayant suivi un cours en automne 2009 (avec SOME)
SELECT name
FROM student
WHERE ID = SOME (
    SELECT ID
    FROM takes
    WHERE semester = 'Fall' AND year = 2009
);


-- 11) Avec NATURAL INNER JOIN
SELECT name
FROM student
NATURAL INNER JOIN takes
WHERE semester = 'Fall' AND year = 2009;


-- 12) Avec EXISTS
SELECT name
FROM student s
WHERE EXISTS (
    SELECT 1
    FROM takes t
    WHERE t.ID = s.ID
      AND t.semester = 'Fall'
      AND t.year = 2009
);


-- 13) Paires d’étudiants ayant suivi au moins un cours ensemble
SELECT DISTINCT s1.name AS etudiant1, s2.name AS etudiant2
FROM takes t1
JOIN takes t2
  ON t1.course_id = t2.course_id
 AND t1.sec_id    = t2.sec_id
 AND t1.semester  = t2.semester
 AND t1.year      = t2.year
JOIN student s1 ON s1.ID = t1.ID
JOIN student s2 ON s2.ID = t2.ID
WHERE s1.ID < s2.ID;


-- 14) Nombre total d’étudiants par enseignant (ayant donné des cours)
SELECT i.name, COUNT(*) AS nb_etudiants
FROM instructor i
JOIN teaches te ON i.ID = te.ID
JOIN takes ta
  ON te.course_id = ta.course_id
 AND te.sec_id    = ta.sec_id
 AND te.semester  = ta.semester
 AND te.year      = ta.year
GROUP BY i.name
ORDER BY nb_etudiants DESC;


-- 15) Même chose mais inclure tous les enseignants (même sans cours)
SELECT i.name, COUNT(ta.ID) AS nb_etudiants
FROM instructor i
LEFT JOIN teaches te ON i.ID = te.ID
LEFT JOIN takes ta
  ON te.course_id = ta.course_id
 AND te.sec_id    = ta.sec_id
 AND te.semester  = ta.semester
 AND te.year      = ta.year
GROUP BY i.name
ORDER BY nb_etudiants DESC;


-- 16) Nombre total de grades A attribués par enseignant
SELECT i.name, COUNT(*) AS nb_A
FROM instructor i
JOIN teaches te ON i.ID = te.ID
JOIN takes ta
  ON te.course_id = ta.course_id
 AND te.sec_id    = ta.sec_id
 AND te.semester  = ta.semester
 AND te.year      = ta.year
WHERE ta.grade = 'A'
GROUP BY i.name;


-- 17) Paires enseignant-étudiant + nombre de fois
SELECT i.name AS enseignant,
       s.name AS etudiant,
       COUNT(*) AS nb_fois
FROM instructor i
JOIN teaches te ON i.ID = te.ID
JOIN takes ta
  ON te.course_id = ta.course_id
 AND te.sec_id    = ta.sec_id
 AND te.semester  = ta.semester
 AND te.year      = ta.year
JOIN student s ON s.ID = ta.ID
GROUP BY i.name, s.name;


-- 18) Paires enseignant-étudiant avec au moins 2 cours
SELECT i.name AS enseignant,
       s.name AS etudiant,
       COUNT(*) AS nb_fois
FROM instructor i
JOIN teaches te ON i.ID = te.ID
JOIN takes ta
  ON te.course_id = ta.course_id
 AND te.sec_id    = ta.sec_id
 AND te.semester  = ta.semester
 AND te.year      = ta.year
JOIN student s ON s.ID = ta.ID
GROUP BY i.name, s.name
HAVING COUNT(*) >= 2;
