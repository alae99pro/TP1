
-- TP n°4 : Introduction au PL/SQL Oracle - Partie I
-- Activer l'affichage : Affichage > Sortie SGBD dans SQL Developer


SET SERVEROUTPUT ON;


-- EXERCICE 1 - Question 1
-- Procédure anonyme : saisie de deux entiers et affichage de leur somme

DECLARE
    v_num1  NUMBER := &premier_entier;   -- Saisie du 1er entier via substitution
    v_num2  NUMBER := &deuxieme_entier;  -- Saisie du 2ème entier via substitution
    v_somme NUMBER;
BEGIN
    v_somme := v_num1 + v_num2;
    DBMS_OUTPUT.PUT_LINE('Somme de ' || v_num1 || ' + ' || v_num2 || ' = ' || v_somme);
END;
/



-- EXERCICE 1 - Question 2
-- Procédure anonyme : saisie d'un nombre et affichage de sa table de multiplication

DECLARE
    v_nombre NUMBER := &nombre;  -- Nombre dont on veut la table de multiplication
    i        NUMBER := 1;        -- Compteur de boucle (de 1 à 10)
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Table de multiplication de ' || v_nombre || ' ===');
    LOOP
        DBMS_OUTPUT.PUT_LINE(v_nombre || ' x ' || i || ' = ' || (v_nombre * i));
        i := i + 1;
        EXIT WHEN i > 10;  -- On s'arrête après 10 multiplications
    END LOOP;
END;
/



-- EXERCICE 1 - Question 3
-- Fonction récursive : calcul de x^n (x et n entiers positifs)

CREATE OR REPLACE FUNCTION puissance(x IN NUMBER, n IN NUMBER)
RETURN NUMBER
IS
BEGIN
    -- Cas de base : tout nombre à la puissance 0 vaut 1
    IF n = 0 THEN
        RETURN 1;
    ELSE
        -- Appel récursif : x^n = x * x^(n-1)
        RETURN x * puissance(x, n - 1);
    END IF;
END;
/

-- Test de la fonction puissance
BEGIN
    DBMS_OUTPUT.PUT_LINE('2^10 = ' || puissance(2, 10));
    DBMS_OUTPUT.PUT_LINE('3^4  = ' || puissance(3, 4));
END;
/



-- EXERCICE 1 - Question 4
-- Procédure anonyme : calcul de la factorielle d'un nombre
-- Le résultat est stocké dans la table resultatFactoriel


-- Création de la table de stockage du résultat (à exécuter une seule fois)
CREATE TABLE resultatFactoriel (
    nombre      NUMBER(10),
    factorielle NUMBER(38)  -- Grand type pour accueillir de grosses valeurs
);

DECLARE
    v_nombre      NUMBER := &nombre_factoriel;  -- Nombre saisi par l'utilisateur
    v_factorielle NUMBER := 1;                  -- Résultat initialisé à 1
    i             NUMBER := 1;                  -- Compteur de boucle
BEGIN
    -- Vérification que le nombre est strictement positif
    IF v_nombre <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Erreur : le nombre doit être strictement positif.');
    ELSE
        -- Calcul itératif de la factorielle : n! = 1 * 2 * 3 * ... * n
        LOOP
            v_factorielle := v_factorielle * i;
            i := i + 1;
            EXIT WHEN i > v_nombre;
        END LOOP;

        -- Insertion du résultat dans la table
        INSERT INTO resultatFactoriel (nombre, factorielle)
        VALUES (v_nombre, v_factorielle);

        DBMS_OUTPUT.PUT_LINE(v_nombre || '! = ' || v_factorielle);
        COMMIT;  -- Validation de la transaction
    END IF;
END;
/



-- EXERCICE 1 - Question 5
-- Calcul et stockage des factorielles des 20 premiers entiers


-- Création de la table de stockage (à exécuter une seule fois)
CREATE TABLE resultatsFactoriels (
    nombre      NUMBER(10),
    factorielle NUMBER(38)
);

DECLARE
    v_factorielle NUMBER := 1;  -- Résultat courant, mis à jour à chaque itération
BEGIN
    -- Boucle principale : on calcule n! pour n allant de 1 à 20
    FOR n IN 1..20 LOOP
        v_factorielle := v_factorielle * n;  -- n! = (n-1)! * n (optimisation)

        -- Insertion de chaque résultat dans la table
        INSERT INTO resultatsFactoriels (nombre, factorielle)
        VALUES (n, v_factorielle);

        DBMS_OUTPUT.PUT_LINE(n || '! = ' || v_factorielle);
    END LOOP;

    COMMIT;  -- Validation de toutes les insertions
END;
/



-- EXERCICE 2 - Création et peuplement de la table emp

CREATE TABLE emp (
    matr    NUMBER(10)    NOT NULL,
    nom     VARCHAR2(50)  NOT NULL,
    sal     NUMBER(7, 2),
    adresse VARCHAR2(96),
    dep     NUMBER(10)    NOT NULL,
    CONSTRAINT emp_pk PRIMARY KEY (matr)
);

-- Insertion de données de test
INSERT INTO emp VALUES (1, 'Alice',  3000, '10 rue de Paris',       75000);
INSERT INTO emp VALUES (2, 'Bob',    2800, '5 avenue Victor Hugo',   92000);
INSERT INTO emp VALUES (3, 'Claire', 3200, '20 boulevard Voltaire',  75000);
INSERT INTO emp VALUES (5, 'David',  2600, '8 rue Nationale',        10);
COMMIT;



-- EXERCICE 2 - Question 1
-- Insertion d'un nouvel employé via %ROWTYPE

DECLARE
    v_employe emp%ROWTYPE;  -- Variable structurée calquée sur la ligne de la table emp
BEGIN
    -- Affectation de chaque attribut de l'enregistrement
    v_employe.matr    := 4;
    v_employe.nom     := 'Youcef';
    v_employe.sal     := 2500;
    v_employe.adresse := 'avenue de la République';
    v_employe.dep     := 92002;

    -- Insertion de l'enregistrement complet en une seule instruction
    INSERT INTO emp VALUES v_employe;

    DBMS_OUTPUT.PUT_LINE('Employé ' || v_employe.nom || ' inséré avec succès.');
    COMMIT;
END;
/



-- EXERCICE 2 - Question 2
-- Suppression des employés d'un département donné
-- Affichage du nombre de lignes supprimées via SQL%ROWCOUNT

DECLARE
    v_nb_lignes NUMBER;         -- Contiendra le nombre de lignes affectées
    v_dep       NUMBER := 10;   -- Département cible de la suppression
BEGIN
    -- Suppression de tous les employés du département spécifié
    DELETE FROM emp WHERE dep = v_dep;

    -- SQL%ROWCOUNT retourne le nombre de lignes affectées par le dernier ordre DML
    v_nb_lignes := SQL%ROWCOUNT;

    DBMS_OUTPUT.PUT_LINE('Nombre d''employés supprimés du dép. ' || v_dep
                         || ' : ' || v_nb_lignes);
    COMMIT;
END;
/



-- EXERCICE 2 - Question 3
-- Calcul de la somme des salaires avec un curseur explicite (LOOP/EXIT WHEN)
-- Équivalent à : SELECT SUM(sal) FROM emp;

DECLARE
    v_salaire emp.sal%TYPE;        -- Variable pour stocker le salaire courant
    v_total   emp.sal%TYPE := 0;   -- Accumulateur initialisé à 0

    -- Déclaration du curseur qui sélectionne tous les salaires
    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;  -- Ouverture du curseur (exécution de la requête)

    LOOP
        FETCH c_salaires INTO v_salaire;          -- Lecture d'une ligne
        EXIT WHEN c_salaires%NOTFOUND;            -- Sortie si plus de lignes

        -- On ignore les salaires NULL pour éviter de fausser le total
        IF v_salaire IS NOT NULL THEN
            v_total := v_total + v_salaire;
        END IF;
    END LOOP;

    CLOSE c_salaires;  -- Libération du curseur

    DBMS_OUTPUT.PUT_LINE('Somme des salaires : ' || v_total);
END;
/



-- EXERCICE 2 - Question 4
-- Calcul du salaire moyen avec un curseur explicite (LOOP/EXIT WHEN)
-- Équivalent à : SELECT AVG(sal) FROM emp;

DECLARE
    v_salaire  emp.sal%TYPE;
    v_total    emp.sal%TYPE  := 0;
    v_nb_emp   NUMBER        := 0;   -- Compteur d'employés avec salaire non NULL
    v_moyenne  NUMBER;

    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    OPEN c_salaires;

    LOOP
        FETCH c_salaires INTO v_salaire;
        EXIT WHEN c_salaires%NOTFOUND;

        IF v_salaire IS NOT NULL THEN
            v_total  := v_total + v_salaire;
            v_nb_emp := v_nb_emp + 1;   -- On compte seulement les salaires valides
        END IF;
    END LOOP;

    CLOSE c_salaires;

    -- Calcul du salaire moyen en évitant la division par zéro
    IF v_nb_emp > 0 THEN
        v_moyenne := v_total / v_nb_emp;
        DBMS_OUTPUT.PUT_LINE('Salaire moyen : ' || ROUND(v_moyenne, 2));
    ELSE
        DBMS_OUTPUT.PUT_LINE('Aucun employé avec un salaire renseigné.');
    END IF;
END;
/



-- EXERCICE 2 - Question 5
-- Réécriture des questions 3 et 4 avec la boucle FOR IN
-- (plus concise : ouverture/fermeture du curseur implicites)


-- Version FOR IN : somme des salaires
DECLARE
    v_total  emp.sal%TYPE := 0;

    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    -- La boucle FOR IN gère automatiquement OPEN, FETCH et CLOSE
    FOR v_rec IN c_salaires LOOP
        IF v_rec.sal IS NOT NULL THEN
            v_total := v_total + v_rec.sal;
        END IF;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('[FOR IN] Somme des salaires : ' || v_total);
END;
/

-- Version FOR IN : salaire moyen
DECLARE
    v_total   emp.sal%TYPE := 0;
    v_nb_emp  NUMBER       := 0;

    CURSOR c_salaires IS
        SELECT sal FROM emp;
BEGIN
    FOR v_rec IN c_salaires LOOP
        IF v_rec.sal IS NOT NULL THEN
            v_total  := v_total + v_rec.sal;
            v_nb_emp := v_nb_emp + 1;
        END IF;
    END LOOP;

    IF v_nb_emp > 0 THEN
        DBMS_OUTPUT.PUT_LINE('[FOR IN] Salaire moyen : '
                             || ROUND(v_total / v_nb_emp, 2));
    END IF;
END;
/



-- EXERCICE 2 - Question 6
-- Affichage des employés de deux départements via un curseur paramétré

DECLARE
    -- Curseur paramétré : p_dep est le paramètre passé à l'ouverture
    CURSOR c(p_dep emp.dep%TYPE) IS
        SELECT dep, nom
        FROM emp
        WHERE dep = p_dep;
BEGIN
    -- Première boucle : employés du département 92000
    DBMS_OUTPUT.PUT_LINE('--- Employés du département 92000 ---');
    FOR v_employe IN c(92000) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || v_employe.nom);
    END LOOP;

    -- Deuxième boucle : employés du département 75000
    DBMS_OUTPUT.PUT_LINE('--- Employés du département 75000 ---');
    FOR v_employe IN c(75000) LOOP
        DBMS_OUTPUT.PUT_LINE('  ' || v_employe.nom);
    END LOOP;
END;
/



-- EXERCICE 3
-- Package de gestion des clients avec surcharge et gestion des exceptions


-- ---------- Spécification du package ----------
CREATE OR REPLACE PACKAGE pkg_gestion_clients AS

    -- Procédure 1 : ajout d'un client avec tous ses attributs individuels
    PROCEDURE ajouter_client(
        p_matr    IN emp.matr%TYPE,
        p_nom     IN emp.nom%TYPE,
        p_sal     IN emp.sal%TYPE,
        p_adresse IN emp.adresse%TYPE,
        p_dep     IN emp.dep%TYPE
    );

    -- Procédure 2 (surcharge) : ajout d'un client via un enregistrement %ROWTYPE
    -- Même nom, signature différente → surcharge PL/SQL
    PROCEDURE ajouter_client(
        p_employe IN emp%ROWTYPE
    );

END pkg_gestion_clients;
/


-- ---------- Corps du package ----------
CREATE OR REPLACE PACKAGE BODY pkg_gestion_clients AS

    -- --------------------------------------------------------
    -- Implémentation de la procédure 1 : paramètres individuels
    -- --------------------------------------------------------
    PROCEDURE ajouter_client(
        p_matr    IN emp.matr%TYPE,
        p_nom     IN emp.nom%TYPE,
        p_sal     IN emp.sal%TYPE,
        p_adresse IN emp.adresse%TYPE,
        p_dep     IN emp.dep%TYPE
    ) IS
    BEGIN
        INSERT INTO emp (matr, nom, sal, adresse, dep)
        VALUES (p_matr, p_nom, p_sal, p_adresse, p_dep);

        DBMS_OUTPUT.PUT_LINE('Client ' || p_nom || ' ajouté (version individuelle).');
        COMMIT;

    EXCEPTION
        -- Violation de la clé primaire : le matricule existe déjà
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : le matricule ' || p_matr
                                 || ' existe déjà dans la base.');
            ROLLBACK;

        -- Violation de contrainte NOT NULL ou autres erreurs de valeur
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : valeur invalide pour l''un des paramètres.');
            ROLLBACK;

        -- Toute autre erreur inattendue
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
            ROLLBACK;
    END ajouter_client;


    -- --------------------------------------------------------
    -- Implémentation de la procédure 2 (surcharge) : via %ROWTYPE
    -- --------------------------------------------------------
    PROCEDURE ajouter_client(
        p_employe IN emp%ROWTYPE
    ) IS
    BEGIN
        -- Insertion directe d'un enregistrement complet
        INSERT INTO emp VALUES p_employe;

        DBMS_OUTPUT.PUT_LINE('Client ' || p_employe.nom
                             || ' ajouté (version ROWTYPE).');
        COMMIT;

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : le matricule ' || p_employe.matr
                                 || ' existe déjà dans la base.');
            ROLLBACK;

        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Erreur : valeur invalide dans l''enregistrement.');
            ROLLBACK;

        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erreur inattendue : ' || SQLERRM);
            ROLLBACK;
    END ajouter_client;

END pkg_gestion_clients;
/



-- Tests du package (Exercice 3)


-- Test 1 : appel via paramètres individuels
BEGIN
    pkg_gestion_clients.ajouter_client(
        p_matr    => 10,
        p_nom     => 'Sophie',
        p_sal     => 3100,
        p_adresse => '15 rue Lecourbe',
        p_dep     => 75000
    );
END;
/

-- Test 2 : appel via ROWTYPE (surcharge)
DECLARE
    v_emp emp%ROWTYPE;
BEGIN
    v_emp.matr    := 11;
    v_emp.nom     := 'Thomas';
    v_emp.sal     := 2900;
    v_emp.adresse := '3 avenue Foch';
    v_emp.dep     := 92000;

    pkg_gestion_clients.ajouter_client(v_emp);
END;
/

-- Test 3 : tentative d'insertion d'un matricule déjà existant (doit lever l'exception)
BEGIN
    pkg_gestion_clients.ajouter_client(
        p_matr    => 10,
        p_nom     => 'Doublon',
        p_sal     => 1000,
        p_adresse => 'nulle part',
        p_dep     => 75000
    );
END;
/
