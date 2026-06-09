<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fourn="http://maroctech.ma/fournisseur"
  xmlns:transp="http://dhlmaroc.ma/transporteur">

  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01//EN"/>

  <!-- ============================================================
       TEMPLATE PRINCIPAL
  ============================================================ -->
  <xsl:template match="/">
    <html lang="fr">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Étiquette de Transport – <xsl:value-of select="//transp:numeroTracking"/></title>
        <style>
          /* ── Imports ─────────────────────────────────────────── */
          @import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&amp;family=IBM+Plex+Mono:wght@400;600&amp;family=IBM+Plex+Sans:wght@300;400;600&amp;display=swap');

          /* ── Variables ───────────────────────────────────────── */
          :root {
            --ink:        #0a0a0a;
            --paper:      #f5f0e8;
            --accent:     #d4380d;
            --accent2:    #1a3a5c;
            --mid:        #6b6b6b;
            --border:     #0a0a0a;
            --label-w:    148mm;
            --label-h:    210mm;
          }

          /*  Reset */
          *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

          body {
            background: #d0cbbf;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            padding: 40px 20px;
            font-family: 'IBM Plex Sans', sans-serif;
            gap: 32px;
          }

          /* Label Card */
          .label {
            width: var(--label-w);
            min-height: var(--label-h);
            background: var(--paper);
            border: 3px solid var(--border);
            box-shadow: 8px 8px 0 var(--ink);
            display: flex;
            flex-direction: column;
            overflow: hidden;
            position: relative;
          }

          /* Header */
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
            font-size: 28px;
            letter-spacing: 2px;
            color: #fff;
            line-height: 1;
          }
          .service-badge {
            background: var(--accent);
            color: #fff;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 9px;
            font-weight: 600;
            padding: 3px 8px;
            border: 1.5px solid #fff;
            text-transform: uppercase;
            letter-spacing: 1px;
            white-space: nowrap;
          }

          /*  Tracking block */
          .tracking-block {
            padding: 10px 14px 8px;
            border-bottom: 2px solid var(--border);
            background: #fff;
          }
          .tracking-label {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 8px;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: var(--mid);
            margin-bottom: 2px;
          }
          .tracking-number {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 26px;
            letter-spacing: 3px;
            color: var(--ink);
            line-height: 1;
          }

          /*  QR / Barcode zone  */
          .code-zone {
            padding: 10px 14px;
            border-bottom: 2px solid var(--border);
            display: flex;
            gap: 12px;
            align-items: center;
            background: var(--paper);
          }
          .qr-box {
            width: 72px;
            height: 72px;
            flex-shrink: 0;
            border: 2px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: center;
            background: #fff;
            position: relative;
            overflow: hidden;
          }
          /* Simulated QR pattern using CSS */
          .qr-box svg { width: 60px; height: 60px; }

          .barcode-wrap {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 3px;
          }
          .barcode-svg { width: 100%; height: 44px; }
          .barcode-num {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 8px;
            text-align: center;
            color: var(--ink);
            letter-spacing: 1px;
          }

          /*  Address sections */
          .addresses {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border-bottom: 2px solid var(--border);
          }
          .addr-block {
            padding: 8px 12px;
          }
          .addr-block:first-child { border-right: 2px solid var(--border); }
          .addr-role {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
            text-transform: uppercase;
            letter-spacing: 2px;
            color: var(--accent);
            margin-bottom: 4px;
            font-weight: 600;
          }
          .addr-name {
            font-weight: 600;
            font-size: 10px;
            color: var(--ink);
            margin-bottom: 2px;
          }
          .addr-line {
            font-size: 9px;
            color: var(--mid);
            line-height: 1.4;
          }

          /* Info grid */
          .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border-bottom: 2px solid var(--border);
          }
          .info-cell {
            padding: 6px 12px;
            border-right: 1px solid #ccc;
            border-bottom: 1px solid #ccc;
          }
          .info-cell:nth-child(2n) { border-right: none; }
          .info-key {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
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

          /*  Products table */
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
            border-bottom: 1px solid var(--border);
          }
          table.products {
            width: 100%;
            border-collapse: collapse;
            font-size: 8px;
          }
          table.products th {
            text-align: left;
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--mid);
            padding: 2px 4px 3px;
            border-bottom: 1px solid var(--border);
          }
          table.products td {
            padding: 3px 4px;
            color: var(--ink);
            line-height: 1.3;
            vertical-align: top;
          }
          table.products tr:nth-child(even) td { background: rgba(0,0,0,0.03); }
          .ref-code { font-family: 'IBM Plex Mono', monospace; font-size: 7px; color: var(--mid); }

          /* Itinerary  */
          .itinerary-section {
            padding: 8px 12px;
            border-bottom: 2px solid var(--border);
          }
          .step {
            display: flex;
            align-items: flex-start;
            gap: 8px;
            padding: 4px 0;
            position: relative;
          }
          .step:not(:last-child)::after {
            content: '';
            position: absolute;
            left: 9px;
            top: 18px;
            width: 1px;
            height: calc(100% - 6px);
            background: var(--border);
          }
          .step-dot {
            width: 19px;
            height: 19px;
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
          .step-dot.active { background: var(--accent); color: #fff; border-color: var(--accent); }
          .step-info { flex: 1; padding-top: 1px; }
          .step-lieu { font-size: 9px; font-weight: 600; color: var(--ink); }
          .step-statut { font-size: 8px; color: var(--mid); }
          .step-date { font-family: 'IBM Plex Mono', monospace; font-size: 7px; color: var(--mid); margin-top: 1px; }
          
          /* Footer  */
          .label-footer {
            background: var(--ink);
            color: #fff;
            padding: 7px 14px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: auto;
          }
          .footer-ref {
            font-family: 'IBM Plex Mono', monospace;
            font-size: 7.5px;
            letter-spacing: 1px;
            color: #aaa;
          }
          .footer-total {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 16px;
            letter-spacing: 1px;
            color: #fff;
          }
          .footer-conditions {
            font-size: 7px;
            color: #aaa;
            text-align: right;
            max-width: 80px;
          }

          /* Print  */
          @media print {
            body { background: #fff; padding: 0; }
            .label { box-shadow: none; border: 1.5px solid #000; }
            .page-title { display: none; }
          }

          /*  Page title (screen only)  */
          .page-title {
            font-family: 'Bebas Neue', sans-serif;
            font-size: 14px;
            letter-spacing: 4px;
            color: #555;
            text-transform: uppercase;
          }
        </style>
      </head>
      <body>

        <p class="page-title">Étiquette de Transport — EAN-COM / EDI</p>

        <div class="label">

          <!-- ── HEADER ── -->
          <div class="label-header">
            <span class="carrier-name">
              <xsl:value-of select="//transp:transporteur/transp:nom"/>
            </span>
            <span class="service-badge">
              <xsl:value-of select="//transp:serviceChoisi"/>
            </span>
          </div>

          <!-- ── TRACKING ── -->
          <div class="tracking-block">
            <div class="tracking-label">Numéro de suivi (Tracking)</div>
            <div class="tracking-number">
              <xsl:value-of select="//transp:numeroTracking"/>
            </div>
          </div>

          <!-- ── QR CODE + BARCODE ── -->
          <div class="code-zone">
            <!-- Simulated QR Code (CSS/SVG pattern) -->
            <div class="qr-box">
              <svg viewBox="0 0 21 21" xmlns="http://www.w3.org/2000/svg" fill="#0a0a0a">
                <!-- Top-left finder -->
                <rect x="0" y="0" width="7" height="7"/><rect x="1" y="1" width="5" height="5" fill="#f5f0e8"/><rect x="2" y="2" width="3" height="3"/>
                <!-- Top-right finder -->
                <rect x="14" y="0" width="7" height="7"/><rect x="15" y="1" width="5" height="5" fill="#f5f0e8"/><rect x="16" y="2" width="3" height="3"/>
                <!-- Bottom-left finder -->
                <rect x="0" y="14" width="7" height="7"/><rect x="1" y="15" width="5" height="5" fill="#f5f0e8"/><rect x="2" y="16" width="3" height="3"/>
                <!-- Data modules (random pattern simulating QR data) -->
                <rect x="8" y="0" width="1" height="1"/><rect x="10" y="0" width="1" height="1"/><rect x="12" y="0" width="1" height="1"/>
                <rect x="8" y="2" width="2" height="1"/><rect x="11" y="2" width="2" height="1"/>
                <rect x="9" y="4" width="1" height="1"/><rect x="11" y="4" width="1" height="1"/><rect x="13" y="4" width="1" height="1"/>
                <rect x="8" y="6" width="1" height="1"/><rect x="10" y="6" width="2" height="1"/>
                <rect x="0" y="8" width="1" height="1"/><rect x="2" y="8" width="2" height="1"/><rect x="6" y="8" width="2" height="1"/><rect x="9" y="8" width="3" height="1"/><rect x="14" y="8" width="2" height="1"/><rect x="18" y="8" width="2" height="1"/>
                <rect x="1" y="10" width="1" height="1"/><rect x="3" y="10" width="2" height="1"/><rect x="7" y="10" width="1" height="1"/><rect x="10" y="10" width="1" height="1"/><rect x="13" y="10" width="3" height="1"/><rect x="18" y="10" width="1" height="1"/><rect x="20" y="10" width="1" height="1"/>
                <rect x="0" y="12" width="2" height="1"/><rect x="4" y="12" width="1" height="1"/><rect x="7" y="12" width="2" height="1"/><rect x="11" y="12" width="2" height="1"/><rect x="15" y="12" width="1" height="1"/><rect x="17" y="12" width="2" height="1"/>
                <rect x="8" y="14" width="1" height="1"/><rect x="10" y="14" width="2" height="1"/><rect x="14" y="14" width="1" height="2"/><rect x="16" y="14" width="2" height="1"/><rect x="19" y="14" width="2" height="1"/>
                <rect x="8" y="16" width="2" height="1"/><rect x="12" y="16" width="1" height="1"/><rect x="15" y="16" width="1" height="1"/><rect x="18" y="16" width="1" height="1"/><rect x="20" y="16" width="1" height="1"/>
                <rect x="9" y="18" width="1" height="1"/><rect x="11" y="18" width="2" height="1"/><rect x="15" y="18" width="2" height="1"/><rect x="19" y="18" width="2" height="1"/>
                <rect x="8" y="20" width="2" height="1"/><rect x="12" y="20" width="1" height="1"/><rect x="14" y="20" width="1" height="1"/><rect x="17" y="20" width="1" height="1"/><rect x="20" y="20" width="1" height="1"/>
              </svg>
            </div>

            <!-- Code-barres SVG (Code 128 simplifié) -->
            <div class="barcode-wrap">
              <svg class="barcode-svg" viewBox="0 0 200 44" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="none">
                <!-- Simulated barcode bars -->
                <rect x="0"   y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="4"   y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="7"   y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="12"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="15"  y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="20"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="23"  y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="28"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="31"  y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="35"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="38"  y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="43"  y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="47"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="50"  y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="54"  y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="59"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="62"  y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="66"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="69"  y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="74"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="77"  y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="81"  y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="86"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="89"  y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="93"  y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="96"  y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="101" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="105" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="108" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="112" y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="117" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="120" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="124" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="127" y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="132" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="136" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="139" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="143" y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="148" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="151" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="155" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="158" y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="163" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="167" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="170" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="174" y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="179" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="182" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="186" y="0" width="3"  height="44" fill="#0a0a0a"/>
                <rect x="191" y="0" width="1"  height="44" fill="#0a0a0a"/>
                <rect x="194" y="0" width="2"  height="44" fill="#0a0a0a"/>
                <rect x="198" y="0" width="2"  height="44" fill="#0a0a0a"/>
              </svg>
              <div class="barcode-num">
                <xsl:value-of select="//transp:numeroTracking"/>
              </div>
            </div>
          </div>

          <!-- ── ADDRESSES ── -->
          <div class="addresses">
            <!-- Expéditeur (Fournisseur) -->
            <div class="addr-block">
              <div class="addr-role">Expéditeur</div>
              <div class="addr-name"><xsl:value-of select="//fourn:fournisseur/fourn:nom"/></div>
              <div class="addr-line"><xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:rue"/></div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:codePostal"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:ville"/>
              </div>
              <div class="addr-line"><xsl:value-of select="//fourn:fournisseur/fourn:adresse/fourn:pays"/></div>
              <div class="addr-line" style="margin-top:3px"><xsl:value-of select="//fourn:fournisseur/fourn:telephone"/></div>
            </div>
            <!-- Destinataire (Client) -->
            <div class="addr-block">
              <div class="addr-role" style="color:#1a3a5c">Destinataire</div>
              <div class="addr-name"><xsl:value-of select="//fourn:client/fourn:nom"/></div>
              <div class="addr-line"><xsl:value-of select="//fourn:client/fourn:adresse/fourn:rue"/></div>
              <div class="addr-line">
                <xsl:value-of select="//fourn:client/fourn:adresse/fourn:codePostal"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="//fourn:client/fourn:adresse/fourn:ville"/>
              </div>
              <div class="addr-line"><xsl:value-of select="//fourn:client/fourn:adresse/fourn:pays"/></div>
              <div class="addr-line" style="margin-top:3px"><xsl:value-of select="//fourn:client/fourn:telephone"/></div>
            </div>
          </div>

          <!-- ── INFO GRID ── -->
          <div class="info-grid">
            <div class="info-cell">
              <div class="info-key">Date Expédition</div>
              <div class="info-val"><xsl:value-of select="//transp:dateExpedition"/></div>
            </div>
            <div class="info-cell">
              <div class="info-key">Livraison Prévue</div>
              <div class="info-val"><xsl:value-of select="//transp:dateLivraisonPrevue"/></div>
            </div>
            <div class="info-cell">
              <div class="info-key">Nombre de Colis</div>
              <div class="info-val"><xsl:value-of select="//transp:nombreColis"/></div>
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
              <div class="info-key">Dimensions (L×l×h)</div>
              <div class="info-val">
                <xsl:value-of select="//transp:longueur"/>×<xsl:value-of select="//transp:largeur"/>×<xsl:value-of select="//transp:hauteur"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="//transp:dimensions/@unite"/>
              </div>
            </div>
            <div class="info-cell">
              <div class="info-key">Emballage</div>
              <div class="info-val"><xsl:value-of select="//transp:typeEmballage"/></div>
            </div>
            <div class="info-cell">
              <div class="info-key">Statut Actuel</div>
              <div class="info-val" style="color:#d4380d"><xsl:value-of select="//transp:statutActuel"/></div>
            </div>
            <div class="info-cell">
              <div class="info-key">Agence</div>
              <div class="info-val"><xsl:value-of select="//transp:agence"/></div>
            </div>
          </div>

          <!-- ── PRODUCTS TABLE ── -->
          <div class="products-section">
            <div class="section-title">Contenu — Lignes de Commande</div>
            <table class="products">
              <thead>
                <tr>
                  <th>#</th>
                  <th>Désignation</th>
                  <th>Réf.</th>
                  <th>Qté</th>
                  <th>P.U.</th>
                  <th>Poids/u</th>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="//fourn:ligne">
                  <tr>
                    <td><xsl:value-of select="@numero"/></td>
                    <td><xsl:value-of select="fourn:produit/fourn:designation"/></td>
                    <td><span class="ref-code"><xsl:value-of select="fourn:produit/fourn:reference"/></span></td>
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

          <!-- ── ITINERARY ── -->
          <div class="itinerary-section">
            <div class="section-title">Itinéraire de Transport</div>
            <xsl:for-each select="//transp:etape">
              <div class="step">
                <div>
                  <xsl:attribute name="class">
                    <xsl:choose>
                      <xsl:when test="transp:statut = //transp:statutActuel">step-dot active</xsl:when>
                      <xsl:otherwise>step-dot</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:value-of select="@ordre"/>
                </div>
                <div class="step-info">
                  <div class="step-lieu"><xsl:value-of select="transp:lieu"/></div>
                  <div class="step-statut"><xsl:value-of select="transp:statut"/></div>
                  <div class="step-date"><xsl:value-of select="transp:date"/></div>
                </div>
              </div>
            </xsl:for-each>
          </div>

          <!-- ── FOOTER ── -->
          <div class="label-footer">
            <div>
              <div class="footer-ref">CMD: <xsl:value-of select="//transp:referenceCommande"/></div>
              <div class="footer-ref"><xsl:value-of select="//fourn:conditionsLivraison"/></div>
            </div>
            <div class="footer-total">
              <xsl:value-of select="//fourn:montantTotal"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="//fourn:montantTotal/@devise"/>
            </div>
            <div class="footer-conditions">Standard<br/>EAN-COM / EDI</div>
          </div>

        </div><!-- /.label -->

      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
