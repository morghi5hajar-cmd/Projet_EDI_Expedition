<?xml version="1.0" encoding="UTF-8"?>
<!--
  ╔══════════════════════════════════════════════════════════════════════════════╗
  ║  transport-label.xsl                                                         ║
  ║  Projet EDI – Système de Suivi d'Expédition International (EAN-COM)          ║
  ║  ENSIAS – Filière SCL                                                         ║
  ║                                                                               ║
  ║  Rôle : Transformer systeme.xml en étiquette de transport HTML5              ║
  ║  Version XSLT : 1.0                                                           ║
  ║  Namespaces utilisés :                                                        ║
  ║    exp   → http://expedition.ma/global       (racine)                         ║
  ║    fourn → http://maroctech.ma/fournisseur   (bon de commande)                ║
  ║    transp→ http://dhlmaroc.ma/transporteur   (bordereau d'expédition)         ║
  ╚══════════════════════════════════════════════════════════════════════════════╝
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exp="http://expedition.ma/global"
  xmlns:fourn="http://maroctech.ma/fournisseur"
  xmlns:transp="http://dhlmaroc.ma/transporteur">

  <!-- ═══════════════════════════════════════════════════════════════
       SORTIE : HTML5 encodé en UTF-8, avec indentation
  ═══════════════════════════════════════════════════════════════════ -->
  <xsl:output
    method="html"
    version="5.0"
    encoding="UTF-8"
    indent="yes"
    doctype-system="about:legacy-compat"/>

  <!-- ═══════════════════════════════════════════════════════════════
       TEMPLATE RACINE
  ═══════════════════════════════════════════════════════════════════ -->
  <xsl:template match="/">
    <html lang="fr">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <!-- Titre dynamique : reprend le numéro de tracking du XML -->
        <title>
          <xsl:text>Étiquette Transport – </xsl:text>
          <xsl:value-of select="//transp:numeroTracking"/>
        </title>

        <style>
          /* ──────────────────────────────────────────────────────────
             TYPOGRAPHIE  (Google Fonts – chargées depuis CDN)
             Bebas Neue  : grands titres / numéros de tracking
             IBM Plex Mono : codes, références, légendes
             IBM Plex Sans : corps de texte
          ────────────────────────────────────────────────────────── */
          @import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&amp;family=IBM+Plex+Mono:wght@400;600&amp;family=IBM+Plex+Sans:wght@300;400;600&amp;display=swap');

          /* ── Variables CSS ──────────────────────────────────────── */
          :root {
            --ink:     #0a0a0a;        /* noir quasi-pur */
            --paper:   #f5f0e8;        /* ivoire doux */
            --accent:  #d4380d;        /* rouge DHL / alerte */
            --accent2: #1a3a5c;        /* bleu marine transporteur */
            --mid:     #6b6b6b;        /* gris texte secondaire */
            --border:  #0a0a0a;
            --label-w: 148mm;          /* largeur étiquette A5 paysage */
          }

          /* ── Reset minimal ──────────────────────────────────────── */
          *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

          /* ── Page (fond gris, centrage) ─────────────────────────── */
          body {
            background: #ccc8be;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: flex-start;
            min-height: 100vh;
            padding: 40px 20px;
            font-family: 'IBM Plex Sans', sans-serif;
            gap: 20px;
            color: var(--ink);
          }

          /* ── Titre de page (affiché à l'écran, masqué à l'impression) */
          .page-title {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 13px;
            letter-spacing: 5px;
            color: #666;
            text-transform: uppercase;
          }

          /* ════════════════════════════════════════════════════════
             CARTE ÉTIQUETTE
          ════════════════════════════════════════════════════════ */
          .label {
            width: var(--label-w);
            background: var(--paper);
            border: 3px solid var(--border);
            box-shadow: 8px 8px 0 rgba(0,0,0,0.5);
            display: flex;
            flex-direction: column;
            overflow: hidden;
          }

          /* ── En-tête transporteur ──────────────────────────────── */
          .label-header {
            background: var(--accent2);
            color: #fff;
            padding: 10px 14px 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            border-bottom: 3px solid var(--border);
          }
          .carrier-name {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 30px;
            letter-spacing: 3px;
            line-height: 1;
          }
          /* Badge service (ex : "Express International") */
          .service-badge {
            background: var(--accent);
            color: #fff;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 8.5px;
            font-weight: 600;
            padding: 3px 9px;
            border: 1.5px solid rgba(255,255,255,0.6);
            text-transform: uppercase;
            letter-spacing: 1px;
            white-space: nowrap;
          }
          /* Logo EAN-COM (coin droit) */
          .ean-badge {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
            color: rgba(255,255,255,0.55);
            text-align: right;
            line-height: 1.5;
          }

          /* ── Bloc numéro de tracking ────────────────────────────── */
          .tracking-block {
            padding: 10px 14px 8px;
            border-bottom: 2px solid var(--border);
            background: #fff;
          }
          .tracking-label {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7.5px;
            text-transform: uppercase;
            letter-spacing: 2.5px;
            color: var(--mid);
            margin-bottom: 2px;
          }
          .tracking-number {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 28px;
            letter-spacing: 3px;
            color: var(--ink);
            line-height: 1;
          }

          /* ════════════════════════════════════════════════════════
             ZONE QR CODE + CODE-BARRES
             ──────────────────────────────────────────────────────
             QR Code : pattern SVG fixe représentant visuellement
             un QR code. Dans un contexte de production, on
             utiliserait une librairie JS (qrcode.js) ou un
             service API (api.qrserver.com?data=TRACKING_NUMBER).
             Ici, le SVG est statique pour rester 100% XSLT 1.0
             sans dépendance externe.

             Code-barres : barres SVG simulant Code 128,
             avec le numéro de tracking affiché en dessous.
          ════════════════════════════════════════════════════════ */
          .code-zone {
            padding: 10px 14px;
            border-bottom: 2px solid var(--border);
            display: flex;
            gap: 14px;
            align-items: center;
            background: var(--paper);
          }
          /* Cadre du QR */
          .qr-frame {
            width: 80px;
            height: 80px;
            flex-shrink: 0;
            border: 2.5px solid var(--border);
            background: #fff;
            padding: 4px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 2px;
          }
          .qr-frame svg { width: 62px; height: 62px; display: block; }
          .qr-caption {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 5.5px;
            color: var(--mid);
            text-align: center;
            letter-spacing: 0.5px;
          }
          /* Côté code-barres */
          .barcode-wrap {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 4px;
          }
          .barcode-svg { width: 100%; height: 48px; display: block; }
          .barcode-num {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 8px;
            text-align: center;
            color: var(--ink);
            letter-spacing: 1.5px;
          }
          .barcode-std {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 6px;
            text-align: center;
            color: var(--mid);
          }

          /* ════════════════════════════════════════════════════════
             ADRESSES : EXPÉDITEUR | DESTINATAIRE
          ════════════════════════════════════════════════════════ */
          .addresses {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border-bottom: 2px solid var(--border);
          }
          .addr-block { padding: 9px 12px; }
          .addr-block:first-child { border-right: 2px solid var(--border); }
          .addr-role {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: var(--accent);
            margin-bottom: 5px;
            font-weight: 600;
          }
          .addr-role.dest { color: var(--accent2); }
          .addr-name {
            font-weight: 600;
            font-size: 10.5px;
            color: var(--ink);
            margin-bottom: 3px;
          }
          .addr-line {
            font-size: 9px;
            color: var(--mid);
            line-height: 1.5;
          }
          .addr-phone {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 8px;
            color: var(--mid);
            margin-top: 4px;
          }

          /* ════════════════════════════════════════════════════════
             GRILLE D'INFORMATIONS LOGISTIQUES
          ════════════════════════════════════════════════════════ */
          .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border-bottom: 2px solid var(--border);
          }
          .info-cell {
            padding: 6px 12px;
            border-right: 1px solid #c8c0b0;
            border-bottom: 1px solid #c8c0b0;
          }
          .info-cell:nth-child(2n) { border-right: none; }
          .info-key {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 6.5px;
            text-transform: uppercase;
            letter-spacing: 1.5px;
            color: var(--mid);
            margin-bottom: 1px;
          }
          .info-val {
            font-size: 10px;
            font-weight: 600;
            color: var(--ink);
          }
          .info-val.alert { color: var(--accent); }

          /* ════════════════════════════════════════════════════════
             TABLEAU PRODUITS
          ════════════════════════════════════════════════════════ */
          .products-section {
            padding: 8px 12px;
            border-bottom: 2px solid var(--border);
          }
          .section-title {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: var(--accent2);
            font-weight: 600;
            margin-bottom: 5px;
            padding-bottom: 3px;
            border-bottom: 1.5px solid var(--border);
          }
          table.products {
            width: 100%;
            border-collapse: collapse;
            font-size: 8px;
          }
          table.products th {
            text-align: left;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 6.5px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--mid);
            padding: 2px 4px 4px;
            border-bottom: 1px solid var(--border);
          }
          table.products td {
            padding: 3px 4px;
            color: var(--ink);
            line-height: 1.4;
            vertical-align: top;
          }
          table.products tr:nth-child(even) td { background: rgba(0,0,0,0.035); }
          .ref-tag {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
            color: var(--accent2);
            background: rgba(26,58,92,0.08);
            padding: 1px 3px;
            border-radius: 2px;
          }

          /* ════════════════════════════════════════════════════════
             ITINÉRAIRE / TIMELINE
          ════════════════════════════════════════════════════════ */
          .itinerary-section {
            padding: 8px 12px;
            border-bottom: 2px solid var(--border);
          }
          .timeline { display: flex; flex-direction: column; gap: 0; }
          .step {
            display: flex;
            align-items: flex-start;
            gap: 10px;
            padding: 5px 0;
            position: relative;
          }
          /* Ligne de connexion entre étapes */
          .step:not(:last-child)::after {
            content: '';
            position: absolute;
            left: 9px;
            top: 20px;
            width: 1.5px;
            height: calc(100% - 8px);
            background: var(--border);
          }
          .step-dot {
            width: 20px;
            height: 20px;
            border: 2px solid var(--border);
            border-radius: 50%;
            background: #fff;
            flex-shrink: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 8px;
            font-weight: 600;
            color: var(--ink);
            z-index: 1;
          }
          /* Étape active (= statutActuel) */
          .step-dot.active {
            background: var(--accent);
            color: #fff;
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(212,56,13,0.2);
          }
          .step-info { flex: 1; padding-top: 1px; }
          .step-lieu  { font-size: 9px; font-weight: 600; color: var(--ink); }
          .step-statut{ font-size: 8px; color: var(--mid); margin-top: 1px; }
          .step-date  {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px; color: var(--mid); margin-top: 1px;
          }

          /* ════════════════════════════════════════════════════════
             PIED DE PAGE
          ════════════════════════════════════════════════════════ */
          .label-footer {
            background: var(--ink);
            color: #fff;
            padding: 8px 14px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 8px;
          }
          .footer-ref {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
            letter-spacing: 1px;
            color: #9a9a9a;
            line-height: 1.7;
          }
          .footer-total {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 18px;
            letter-spacing: 1px;
            color: #fff;
            text-align: center;
          }
          .footer-total small {
            display: block;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 6.5px;
            letter-spacing: 1px;
            color: #9a9a9a;
            font-weight: 400;
          }
          .footer-edi {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 6.5px;
            color: #777;
            text-align: right;
            line-height: 1.8;
          }

          /* ════════════════════════════════════════════════════════
             IMPRESSION (Ctrl+P)
          ════════════════════════════════════════════════════════ */
          @media print {
            body { background: #fff; padding: 0; gap: 0; }
            .label { box-shadow: none; border: 2px solid #000; width: 148mm; }
            .page-title { display: none; }
          }
        </style>
      </head>
      <body>

        <!-- Titre visible à l'écran uniquement -->
        <p class="page-title">Étiquette de Transport · Standard EAN-COM / EDI</p>

        <div class="label">

          <!-- ══════════════════════════════════════════
               1. EN-TÊTE : NOM TRANSPORTEUR + SERVICE
          ══════════════════════════════════════════ -->
          <div class="label-header">
            <span class="carrier-name">
              <xsl:value-of select="//transp:transporteur/transp:nom"/>
            </span>
            <span class="service-badge">
              <xsl:value-of select="//transp:serviceChoisi"/>
            </span>
            <span class="ean-badge">EAN-COM<br/>EDI STD</span>
          </div>

          <!-- ══════════════════════════════════════════
               2. NUMÉRO DE TRACKING (grand affichage)
          ══════════════════════════════════════════ -->
          <div class="tracking-block">
            <div class="tracking-label">Numéro de Suivi · Tracking Number</div>
            <div class="tracking-number">
              <xsl:value-of select="//transp:numeroTracking"/>
            </div>
          </div>

          <!-- ══════════════════════════════════════════
               3. QR CODE + CODE-BARRES
               ─────────────────────────────────────────
               QR Code : SVG statique représentant un
               QR code visuel. Le numéro de tracking est
               encodé dans les modules noirs (pattern).
               ─────────────────────────────────────────
               En production : remplacer le SVG par :
               <img src="https://api.qrserver.com/v1/create-qr-code/
                    ?data=DHL-MA-2025-98734&amp;size=80x80"/>
               ─────────────────────────────────────────
               Code-barres Code 128 : barres SVG simulées,
               le numéro de tracking apparaît en clair.
          ══════════════════════════════════════════ -->
          <div class="code-zone">

            <!-- QR Code (SVG représentatif) -->
            <div class="qr-frame">
              <svg viewBox="0 0 21 21" xmlns="http://www.w3.org/2000/svg" fill="#0a0a0a">
                <!-- Coin détecteur haut-gauche -->
                <rect x="0" y="0" width="7" height="7"/>
                <rect x="1" y="1" width="5" height="5" fill="#f5f0e8"/>
                <rect x="2" y="2" width="3" height="3"/>
                <!-- Coin détecteur haut-droit -->
                <rect x="14" y="0" width="7" height="7"/>
                <rect x="15" y="1" width="5" height="5" fill="#f5f0e8"/>
                <rect x="16" y="2" width="3" height="3"/>
                <!-- Coin détecteur bas-gauche -->
                <rect x="0" y="14" width="7" height="7"/>
                <rect x="1" y="15" width="5" height="5" fill="#f5f0e8"/>
                <rect x="2" y="16" width="3" height="3"/>
                <!-- Modules de données (représentation du numéro de tracking) -->
                <rect x="8"  y="0"  width="1" height="1"/>
                <rect x="10" y="0"  width="2" height="1"/>
                <rect x="13" y="0"  width="1" height="1"/>
                <rect x="9"  y="2"  width="2" height="1"/>
                <rect x="12" y="2"  width="1" height="1"/>
                <rect x="8"  y="4"  width="1" height="1"/>
                <rect x="11" y="4"  width="2" height="1"/>
                <rect x="9"  y="6"  width="1" height="1"/>
                <rect x="12" y="6"  width="2" height="1"/>
                <rect x="0"  y="8"  width="1" height="1"/>
                <rect x="2"  y="8"  width="2" height="1"/>
                <rect x="5"  y="8"  width="2" height="1"/>
                <rect x="8"  y="8"  width="3" height="1"/>
                <rect x="13" y="8"  width="2" height="1"/>
                <rect x="17" y="8"  width="1" height="1"/>
                <rect x="19" y="8"  width="2" height="1"/>
                <rect x="1"  y="10" width="2" height="1"/>
                <rect x="4"  y="10" width="1" height="1"/>
                <rect x="7"  y="10" width="2" height="1"/>
                <rect x="10" y="10" width="1" height="1"/>
                <rect x="13" y="10" width="2" height="1"/>
                <rect x="17" y="10" width="3" height="1"/>
                <rect x="0"  y="12" width="3" height="1"/>
                <rect x="5"  y="12" width="1" height="1"/>
                <rect x="8"  y="12" width="2" height="1"/>
                <rect x="12" y="12" width="1" height="1"/>
                <rect x="15" y="12" width="2" height="1"/>
                <rect x="19" y="12" width="2" height="1"/>
                <rect x="8"  y="14" width="1" height="1"/>
                <rect x="10" y="14" width="2" height="1"/>
                <rect x="14" y="14" width="2" height="1"/>
                <rect x="18" y="14" width="3" height="1"/>
                <rect x="9"  y="16" width="2" height="1"/>
                <rect x="13" y="16" width="1" height="1"/>
                <rect x="16" y="16" width="2" height="1"/>
                <rect x="20" y="16" width="1" height="1"/>
                <rect x="8"  y="18" width="1" height="1"/>
                <rect x="11" y="18" width="2" height="1"/>
                <rect x="15" y="18" width="2" height="1"/>
                <rect x="19" y="18" width="2" height="1"/>
                <rect x="9"  y="20" width="2" height="1"/>
                <rect x="13" y="20" width="1" height="1"/>
                <rect x="16" y="20" width="1" height="1"/>
                <rect x="19" y="20" width="2" height="1"/>
              </svg>
              <div class="qr-caption">QR · TRACKING</div>
            </div>

            <!-- Code-barres Code 128 (SVG simulé) -->
            <div class="barcode-wrap">
              <svg class="barcode-svg" viewBox="0 0 200 48"
                   xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
                <!-- Barres simulant un code-barres Code 128 -->
                <rect x="0"   y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="4"   y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="7"   y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="12"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="15"  y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="20"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="23"  y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="28"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="31"  y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="35"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="38"  y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="43"  y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="47"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="50"  y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="54"  y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="59"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="62"  y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="66"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="69"  y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="74"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="77"  y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="81"  y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="86"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="89"  y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="93"  y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="96"  y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="101" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="105" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="108" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="112" y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="117" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="120" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="124" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="127" y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="132" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="136" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="139" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="143" y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="148" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="151" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="155" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="158" y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="163" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="167" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="170" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="174" y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="179" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="182" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="186" y="0" width="3"  height="48" fill="#0a0a0a"/>
                <rect x="191" y="0" width="1"  height="48" fill="#0a0a0a"/>
                <rect x="194" y="0" width="2"  height="48" fill="#0a0a0a"/>
                <rect x="198" y="0" width="2"  height="48" fill="#0a0a0a"/>
              </svg>
              <!-- Numéro extrait dynamiquement du XML -->
              <div class="barcode-num">
                <xsl:value-of select="//transp:numeroTracking"/>
              </div>
              <div class="barcode-std">Code 128 · EAN-COM</div>
            </div>
          </div>

          <!-- ══════════════════════════════════════════
               4. ADRESSES : EXPÉDITEUR | DESTINATAIRE
               Données issues du namespace fourn:
               (http://maroctech.ma/fournisseur)
          ══════════════════════════════════════════ -->
          <div class="addresses">

            <!-- Expéditeur = fournisseur -->
            <div class="addr-block">
              <div class="addr-role">▲ Expéditeur (From)</div>
              <div class="addr-name">
                <xsl:value-of select="//fourn:fournisseur/fourn:nom"/>
              </div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:rue"/>
              </div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:codePostal"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:ville"/>
              </div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:pays"/>
              </div>
              <div class="addr-phone">
                <xsl:value-of select="//fourn:fournisseur/fourn:telephone"/>
              </div>
            </div>

            <!-- Destinataire = client -->
            <div class="addr-block">
              <div class="addr-role dest">▼ Destinataire (To)</div>
              <div class="addr-name">
                <xsl:value-of select="//fourn:client/fourn:nom"/>
              </div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:client/fourn:adresse/fourn:rue"/>
              </div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:client/fourn:adresse/fourn:codePostal"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="//fourn:client/fourn:adresse/fourn:ville"/>
              </div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:client/fourn:adresse/fourn:pays"/>
              </div>
              <div class="addr-phone">
                <xsl:value-of select="//fourn:client/fourn:telephone"/>
              </div>
            </div>
          </div>

          <!-- ══════════════════════════════════════════
               5. GRILLE D'INFORMATIONS LOGISTIQUES
               Données issues du namespace transp:
               (http://dhlmaroc.ma/transporteur)
          ══════════════════════════════════════════ -->
          <div class="info-grid">

            <div class="info-cell">
              <div class="info-key">Date Expédition</div>
              <div class="info-val">
                <xsl:value-of select="//transp:dateExpedition"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Livraison Prévue</div>
              <div class="info-val">
                <xsl:value-of select="//transp:dateLivraisonPrevue"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Nombre de Colis</div>
              <div class="info-val">
                <xsl:value-of select="//transp:nombreColis"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Poids Total</div>
              <div class="info-val">
                <xsl:value-of select="//transp:poidsTotal"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="//transp:poidsTotal/@unite"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Dimensions (L × l × h)</div>
              <div class="info-val">
                <xsl:value-of select="//transp:longueur"/>
                <xsl:text> × </xsl:text>
                <xsl:value-of select="//transp:largeur"/>
                <xsl:text> × </xsl:text>
                <xsl:value-of select="//transp:hauteur"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="//transp:dimensions/@unite"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Type Emballage</div>
              <div class="info-val">
                <xsl:value-of select="//transp:typeEmballage"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Statut Actuel</div>
              <!-- Mise en rouge pour signaler l'état en cours -->
              <div class="info-val alert">
                <xsl:value-of select="//transp:statutActuel"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Agence DHL</div>
              <div class="info-val">
                <xsl:value-of select="//transp:agence"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">N° Commande</div>
              <div class="info-val">
                <xsl:value-of select="//fourn:numeroCommande"/>
              </div>
            </div>

            <div class="info-cell">
              <div class="info-key">Date Commande</div>
              <div class="info-val">
                <xsl:value-of select="//fourn:dateCommande"/>
              </div>
            </div>

          </div>

          <!-- ══════════════════════════════════════════
               6. TABLEAU PRODUITS (lignes de commande)
               Données issues du namespace fourn:
          ══════════════════════════════════════════ -->
          <div class="products-section">
            <div class="section-title">Contenu — Lignes de Commande</div>
            <table class="products">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Désignation</th>
                  <th>Référence</th>
                  <th>Qté</th>
                  <th>Prix Unit.</th>
                  <th>Poids/u</th>
                </tr>
              </thead>
              <tbody>
                <!-- Boucle sur chaque ligne de commande -->
                <xsl:for-each select="//fourn:ligne">
                  <tr>
                    <td><xsl:value-of select="@numero"/></td>
                    <td><xsl:value-of select="fourn:produit/fourn:designation"/></td>
                    <td>
                      <span class="ref-tag">
                        <xsl:value-of select="fourn:produit/fourn:reference"/>
                      </span>
                    </td>
                    <td><xsl:value-of select="fourn:produit/fourn:quantite"/></td>
                    <td>
                      <xsl:value-of select="fourn:produit/fourn:prixUnitaire"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="fourn:produit/fourn:prixUnitaire/@devise"/>
                    </td>
                    <td>
                      <xsl:value-of select="fourn:produit/fourn:poidsUnitaire"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of select="fourn:produit/fourn:poidsUnitaire/@unite"/>
                    </td>
                  </tr>
                </xsl:for-each>
              </tbody>
            </table>
          </div>

          <!-- ══════════════════════════════════════════
               7. ITINÉRAIRE DE TRANSPORT (timeline)
               Données issues du namespace transp:
               L'étape dont le statut = statutActuel
               est mise en surbrillance (point rouge).
          ══════════════════════════════════════════ -->
          <div class="itinerary-section">
            <div class="section-title">Itinéraire de Transport</div>
            <div class="timeline">
              <xsl:for-each select="//transp:etape">
                <div class="step">
                  <!-- Le point de la timeline est coloré en rouge si c'est l'étape active -->
                  <div>
                    <xsl:attribute name="class">
                      <xsl:choose>
                        <xsl:when test="transp:statut = //transp:statutActuel">
                          <xsl:text>step-dot active</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text>step-dot</xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="@ordre"/>
                  </div>
                  <div class="step-info">
                    <div class="step-lieu">
                      <xsl:value-of select="transp:lieu"/>
                    </div>
                    <div class="step-statut">
                      <xsl:value-of select="transp:statut"/>
                    </div>
                    <div class="step-date">
                      <xsl:value-of select="transp:date"/>
                    </div>
                  </div>
                </div>
              </xsl:for-each>
            </div>
          </div>

          <!-- ══════════════════════════════════════════
               8. PIED DE PAGE : RÉFÉRENCE + MONTANT
          ══════════════════════════════════════════ -->
          <div class="label-footer">
            <div class="footer-ref">
              <div>CMD : <xsl:value-of select="//transp:referenceCommande"/></div>
              <div>
                <xsl:value-of select="//fourn:conditionsLivraison"/>
              </div>
            </div>
            <div class="footer-total">
              <xsl:value-of select="//fourn:montantTotal"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="//fourn:montantTotal/@devise"/>
              <small>Montant Total</small>
            </div>
            <div class="footer-edi">
              Standard EAN-COM<br/>
              EDI · ENSIAS SCL<br/>
              <xsl:value-of select="//transp:transporteur/transp:contact"/>
            </div>
          </div>

        </div><!-- /.label -->

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
