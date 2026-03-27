import itertools

# TP n°2 - Exercice 4

# Données
myrelations = [
    {'A', 'B', 'C', 'G', 'H', 'I'},
    {'X', 'Y'}
]

mydependencies = [
    [{'A'}, {'B'}],
    [{'A'}, {'C'}],
    [{'C', 'G'}, {'H'}],
    [{'C', 'G'}, {'I'}],
    [{'B'}, {'H'}]
]

# 1. Afficher les dépendances
def printDependencies(F):
    for alpha, beta in F:
        print("\t", alpha, "-->", beta)

# 2. Afficher les relations
def printRelations(T):
    for R in T:
        print("\t", R)

# 3. Power set (avec ensemble vide)
def powerSet(inputset):
    result = [set()]
    for r in range(1, len(inputset) + 1):
        result += list(map(set, itertools.combinations(inputset, r)))
    return result

# 4. Fermeture d'un ensemble
def closure(F, K):
    result = set(K)
    changed = True

    while changed:
        changed = False
        for alpha, beta in F:
            if set(alpha).issubset(result):
                new_result = result.union(set(beta))
                if new_result != result:
                    result = new_result
                    changed = True

    return result

# 5. Fermeture de F (restreinte à R)
def closureF(F, R):
    result = []
    subsets = powerSet(R)

    for alpha in subsets:
        alpha_plus = closure(F, alpha) & R
        for attr in alpha_plus:
            if attr not in alpha:
                result.append([set(alpha), {attr}])

    return result

# 6. Détermination fonctionnelle
def determines(F, alpha, beta):
    return set(beta).issubset(closure(F, alpha))

# 7. Super clé
def isSuperKey(F, R, K):
    return (closure(F, K) & R) == R

# 8. Clé candidate
def isCandidateKey(F, R, K):
    K = set(K)

    if not isSuperKey(F, R, K):
        return False

    for subset in powerSet(K):
        subset = set(subset)
        if subset != K and isSuperKey(F, R, subset):
            return False

    return True

# 9. Toutes les clés candidates
def allCandidateKeys(F, R):
    keys = []
    for subset in powerSet(R):
        if isCandidateKey(F, R, subset):
            keys.append(subset)
    return keys

# 10. Toutes les super clés
def allSuperKeys(F, R):
    superkeys = []
    for subset in powerSet(R):
        if isSuperKey(F, R, subset):
            superkeys.append(subset)
    return superkeys

# 11. Une clé candidate
def oneCandidateKey(F, R):
    for subset in powerSet(R):
        if isCandidateKey(F, R, subset):
            return subset
    return set()

# 12. Test BCNF
def isBCNF(F, R):
    for alpha, beta in closureF(F, R):
        if beta.issubset(alpha):
            continue
        if not isSuperKey(F, R, alpha):
            return False
    return True

# 13. Schéma BCNF
def isSchemaBCNF(F, T):
    for R in T:
        if not isBCNF(F, R):
            return False
    return True

# 14. Décomposition BCNF
def bcnfDecomposition(F, R):
    result = [R]
    changed = True

    while changed:
        changed = False

        for Ri in result:
            for alpha, beta in closureF(F, Ri):
                if beta.issubset(alpha):
                    continue

                if not isSuperKey(F, Ri, alpha):
                    alpha_plus = closure(F, alpha) & Ri

                    R1 = set(alpha_plus)
                    R2 = (Ri - alpha_plus) | set(alpha)

                    result.remove(Ri)
                    result.append(R1)
                    result.append(R2)

                    changed = True
                    break

            if changed:
                break

    return result


# TESTS
if __name__ == "__main__":

    R_ex = {'A', 'B', 'C', 'G', 'H', 'I'}
    F_ex = mydependencies

    print("=" * 50)
    print("1. Dépendances :")
    printDependencies(F_ex)

    print("\n2. Relations :")
    printRelations(myrelations)

    print("\n3. PowerSet de {A,B,C} :")
    for s in powerSet({'A', 'B', 'C'}):
        print("\t", s)

    print("\n4. Fermetures :")
    print("A+ =", closure(F_ex, {'A'}))
    print("CG+ =", closure(F_ex, {'C', 'G'}))
    print("AB+ =", closure(F_ex, {'A', 'B'}))

    print("\n5. Fermeture de F :")
    for dep in closureF(F_ex, R_ex):
        print("\t", dep[0], "-->", dep[1])

    print("\n6. Déterminations :")
    print("A -> B ?", determines(F_ex, {'A'}, {'B'}))
    print("A -> H ?", determines(F_ex, {'A'}, {'H'}))
    print("B -> G ?", determines(F_ex, {'B'}, {'G'}))

    print("\n7. Super clés :")
    print("{A,G} ?", isSuperKey(F_ex, R_ex, {'A', 'G'}))
    print("{A} ?", isSuperKey(F_ex, R_ex, {'A'}))

    print("\n8. Clés candidates :")
    print("{A,G} ?", isCandidateKey(F_ex, R_ex, {'A', 'G'}))

    print("\n9. Toutes les clés candidates :")
    for k in allCandidateKeys(F_ex, R_ex):
        print("\t", k)

    print("\n10. Toutes les super clés :")
    for sk in allSuperKeys(F_ex, R_ex):
        print("\t", sk)

    print("\n11. Une clé candidate :", oneCandidateKey(F_ex, R_ex))

    print("\n12. R en BCNF ?", isBCNF(F_ex, R_ex))

    print("\n13. Schéma en BCNF ?", isSchemaBCNF(F_ex, myrelations))

    print("\n14. Décomposition BCNF :")
    for r in bcnfDecomposition(F_ex, R_ex):
        print("\t", r)
