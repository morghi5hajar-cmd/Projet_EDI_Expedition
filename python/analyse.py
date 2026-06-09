# ============================================================
# Projet XML — Filière SCL | ENSIAS 2025/2026
# Système de Suivi d'Expédition International (EAN-COM)
# main.py — Script principal
# ============================================================

from lxml import etree
import os

# ── Chemins des fichiers ──────────────────────────────────
XML_FILE  = "../xsd/fichierxml.xml"
XSD_FILE  = "../xsd/expedition.xsd"
XSLT_FILE = "../xslt/expedition.xslt"
HTML_OUT  = "../html/etiquette.html"

# ── Couleurs terminal ─────────────────────────────────────
VERT  = "\033[92m"
ROUGE = "\033[91m"
JAUNE = "\033[93m"
BLEU  = "\033[94m"
RESET = "\033[0m"
GRAS  = "\033[1m"

def titre(texte):
    print(f"\n{BLEU}{GRAS}{'='*55}{RESET}")
    print(f"{BLEU}{GRAS}  {texte}{RESET}")
    print(f"{BLEU}{GRAS}{'='*55}{RESET}")

def ok(texte):    print(f"  {VERT}✅  {texte}{RESET}")
def erreur(texte): print(f"  {ROUGE}❌  {texte}{RESET}")
def info(texte):  print(f"  {JAUNE}ℹ️   {texte}{RESET}")

# ── Namespaces ────────────────────────────────────────────
NS = {
    "exp"   : "http://expedition.ma/global",
    "fourn" : "http://maroctech.ma/fournisseur",
    "transp": "http://dhlmaroc.ma/transporteur"
}

# ── ÉTAPE 1 : Chargement XML ──────────────────────────────
def charger_xml(path):
    titre("ÉTAPE 1 — Chargement du fichier XML")
    if not os.path.exists(path):
        erreur(f"Fichier introuvable : {path}")
        return None
    try:
        tree = etree.parse(path)
        ok(f"Fichier XML chargé : {path}")
        root = tree.getroot()
        info(f"Élément racine : <{root.tag}>")
        info(f"Namespaces : exp | fourn | transp")
        return tree
    except etree.XMLSyntaxError as e:
        erreur(f"Erreur syntaxe XML : {e}")
        return None

# ── ÉTAPE 2 : Validation XSD ──────────────────────────────
def valider_xsd(tree, xsd_path):
    titre("ÉTAPE 2 — Validation contre le schéma XSD")
    if not os.path.exists(xsd_path):
        erreur(f"Fichier XSD introuvable : {xsd_path}")
        return False
    try:
        schema  = etree.XMLSchema(etree.parse(xsd_path))
        valide  = schema.validate(tree)
        if valide:
            ok("XML valide — toutes les règles XSD respectées ✅")
        else:
            erreur("XML invalide — erreurs XSD :")
            for e in schema.error_log:
                print(f"     → Ligne {e.line} : {e.message}")
        return valide
    except Exception as e:
        erreur(f"Erreur validation : {e}")
        return False

# ── ÉTAPE 3 : Extraction des données ─────────────────────
def extraire_donnees(tree):
    titre("ÉTAPE 3 — Extraction des données XML")
    root = tree.getroot()

    def get(xpath):
        r = root.find(xpath, NS)
        return r.text if r is not None else "N/A"

    donnees = {
        "numero_commande" : get(".//fourn:numeroCommande"),
        "date_commande"   : get(".//fourn:dateCommande"),
        "fournisseur"     : get(".//fourn:fournisseur/fourn:nom"),
        "ville_fourn"     : get(".//fourn:fournisseur/fourn:adresse/fourn:ville"),
        "client"          : get(".//fourn:client/fourn:nom"),
        "ville_client"    : get(".//fourn:client/fourn:adresse/fourn:ville"),
        "montant_total"   : get(".//fourn:montantTotal"),
        "numero_tracking" : get(".//transp:numeroTracking"),
        "date_expedition" : get(".//transp:dateExpedition"),
        "date_livraison"  : get(".//transp:dateLivraisonPrevue"),
        "transporteur"    : get(".//transp:transporteur/transp:nom"),
        "poids_total"     : get(".//transp:poidsTotal"),
        "statut_actuel"   : get(".//transp:statutActuel"),
        "service"         : get(".//transp:serviceChoisi"),
    }

    print()
    print(f"  {GRAS}BON DE COMMANDE{RESET}")
    print(f"  {'─'*50}")
    ok(f"N° Commande  : {donnees['numero_commande']}")
    ok(f"Date         : {donnees['date_commande']}")
    ok(f"Fournisseur  : {donnees['fournisseur']} ({donnees['ville_fourn']})")
    ok(f"Client       : {donnees['client']} ({donnees['ville_client']})")
    ok(f"Montant      : {donnees['montant_total']} EUR")
    print()
    print(f"  {GRAS}BORDEREAU D'EXPÉDITION{RESET}")
    print(f"  {'─'*50}")
    ok(f"N° Tracking  : {donnees['numero_tracking']}")
    ok(f"Transporteur : {donnees['transporteur']}")
    ok(f"Expédition   : {donnees['date_expedition']}")
    ok(f"Livraison    : {donnees['date_livraison']}")
    ok(f"Poids        : {donnees['poids_total']} kg")
    ok(f"Statut       : {donnees['statut_actuel']}")
    ok(f"Service      : {donnees['service']}")

    produits = root.findall(".//fourn:produit", NS)
    print()
    info(f"{len(produits)} produit(s) dans la commande :")
    for p in produits:
        des = p.find("fourn:designation", NS)
        ref = p.find("fourn:reference",   NS)
        qty = p.find("fourn:quantite",    NS)
        print(f"     • {des.text} (ref: {ref.text}) — Qté: {qty.text}")

    return donnees

# ── ÉTAPE 4 : Transformation XSLT ────────────────────────
def transformer_xslt(tree, xslt_path, output_path):
    titre("ÉTAPE 4 — Transformation XSLT → HTML")
    if not os.path.exists(xslt_path):
        erreur(f"Fichier XSLT introuvable : {xslt_path}")
        return False
    try:
        transform = etree.XSLT(etree.parse(xslt_path))
        result    = transform(tree)
        with open(output_path, "wb") as f:
            f.write(bytes(result))
        ok(f"Étiquette HTML générée : {output_path}")
        return True
    except Exception as e:
        erreur(f"Erreur XSLT : {e}")
        return False

# ── ÉTAPE 5 : Rapport final ───────────────────────────────
def rapport_final(xml_ok, xsd_ok, donnees, html_ok):
    titre("ÉTAPE 5 — Rapport Final")
    print()
    print(f"  {'─'*40}")
    print(f"  Chargement XML     : {'✅ OK'    if xml_ok  else '❌ ÉCHEC'}")
    print(f"  Validation XSD     : {'✅ OK'    if xsd_ok  else '❌ ÉCHEC'}")
    print(f"  Extraction données : {'✅ OK'    if donnees else '❌ ÉCHEC'}")
    print(f"  Génération HTML    : {'✅ OK'    if html_ok else '❌ ÉCHEC'}")
    print()
    if donnees:
        print(f"  {GRAS}{donnees['fournisseur']} → {donnees['client']}{RESET}")
        print(f"  Tracking : {donnees['numero_tracking']}")
        print(f"  Statut   : {donnees['statut_actuel']}")
    print(f"\n  {VERT}{GRAS}Projet XML SCL — ENSIAS 2025/2026 ✅{RESET}\n")

# ── MAIN ─────────────────────────────────────────────────
if __name__ == "__main__":
    print(f"\n{GRAS}{'='*55}")
    print("  SYSTÈME DE SUIVI D'EXPÉDITION INTERNATIONAL")
    print("  Standard EAN-COM — Filière SCL ENSIAS")
    print(f"{'='*55}{RESET}")

    tree    = charger_xml(XML_FILE)
    xsd_ok  = valider_xsd(tree, XSD_FILE)        if tree else False
    donnees = extraire_donnees(tree)              if tree else None
    html_ok = transformer_xslt(tree, XSLT_FILE, HTML_OUT) if tree else False

    rapport_final(tree is not None, xsd_ok, donnees, html_ok)