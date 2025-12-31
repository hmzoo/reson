class Main extends hxd.App {
    var graphics:h2d.Graphics;
    var mass1:Float = 1.0;           // Masse 1 (kg)
    var stiffness1:Float = 100.0;    // Rigidité du ressort 1 (N/m)
    var position1:Float = 200.0;     // Position de la masse 1
    var velocity1:Float = 0.0;       // Vitesse de la masse 1
    var equilibriumPosition1:Float = 200.0; // Position d'équilibre du ressort 1
    
    var mass2:Float = 1.0;           // Masse 2 (kg)
    var stiffness2:Float = 100.0;    // Rigidité du ressort 2 (N/m)
    var position2:Float = 400.0;     // Position de la masse 2
    var velocity2:Float = 0.0;       // Vitesse de la masse 2
    var equilibriumLength2:Float = 200.0; // Longueur au repos du ressort 2
    
    var centerX:Float = 400;
    var centerY:Float = 600;        // Point d'ancrage en bas (sol)
    var isDragging:Bool = false;
    var draggedMass:Int = 0; // 0 = aucune, 1 = masse1, 2 = masse2
    
    // Tracé des courbes
    var historyPos1:Array<Float> = [];
    var historyPos2:Array<Float> = [];
    var maxHistorySize:Int = 200;
    var graphicsHistory:h2d.Graphics;
    
    var mass1Slider:Slider;
    var stiffness1Slider:Slider;
    var mass2Slider:Slider;
    var stiffness2Slider:Slider;
    var mass1Text:h2d.Text;
    var stiffness1Text:h2d.Text;
    var mass2Text:h2d.Text;
    var stiffness2Text:h2d.Text;
    var frequencyText:h2d.Text;
    
    override function init() {
        engine.backgroundColor = 0xFFFFFF;
        
        // Graphics pour dessiner
        graphics = new h2d.Graphics(s2d);
        graphicsHistory = new h2d.Graphics(s2d);
        
        // Création de l'interface
        createUI();
    }
    
    function createUI() {
        var font = hxd.res.DefaultFont.get();
        
        // Titre
        var title = new h2d.Text(font, s2d);
        title.text = "Simulation de Résonance - Système à 2 Étages";
        title.textColor = 0x000000;
        title.x = 20;
        title.y = 20;
        title.scale(1.5);
        
        // === MASSE 1 ===
        var mass1Label = new h2d.Text(font, s2d);
        mass1Label.text = "Masse 1 (kg):";
        mass1Label.textColor = 0x000000;
        mass1Label.x = 50;
        mass1Label.y = 450;
        
        mass1Text = new h2d.Text(font, s2d);
        mass1Text.textColor = 0x000000;
        mass1Text.x = 200;
        mass1Text.y = 450;
        
        mass1Slider = new Slider(s2d, 50, 480, 300, 0.1, 5.0, mass1);
        
        // === RIGIDITÉ 1 ===
        var stiffness1Label = new h2d.Text(font, s2d);
        stiffness1Label.text = "Rigidité 1 (N/m):";
        stiffness1Label.textColor = 0x000000;
        stiffness1Label.x = 50;
        stiffness1Label.y = 520;
        
        stiffness1Text = new h2d.Text(font, s2d);
        stiffness1Text.textColor = 0x000000;
        stiffness1Text.x = 200;
        stiffness1Text.y = 520;
        
        stiffness1Slider = new Slider(s2d, 50, 550, 300, 10, 500, stiffness1);
        
        // === MASSE 2 ===
        var mass2Label = new h2d.Text(font, s2d);
        mass2Label.text = "Masse 2 (kg):";
        mass2Label.textColor = 0x000000;
        mass2Label.x = 450;
        mass2Label.y = 450;
        
        mass2Text = new h2d.Text(font, s2d);
        mass2Text.textColor = 0x000000;
        mass2Text.x = 600;
        mass2Text.y = 450;
        
        mass2Slider = new Slider(s2d, 450, 480, 300, 0.1, 5.0, mass2);
        
        // === RIGIDITÉ 2 ===
        var stiffness2Label = new h2d.Text(font, s2d);
        stiffness2Label.text = "Rigidité 2 (N/m):";
        stiffness2Label.textColor = 0x000000;
        stiffness2Label.x = 450;
        stiffness2Label.y = 520;
        
        stiffness2Text = new h2d.Text(font, s2d);
        stiffness2Text.textColor = 0x000000;
        stiffness2Text.x = 600;
        stiffness2Text.y = 520;
        
        stiffness2Slider = new Slider(s2d, 450, 550, 300, 10, 500, stiffness2);
        
        // Fréquence naturelle
        var freqLabel = new h2d.Text(font, s2d);
        freqLabel.text = "Fréquences propres:";
        freqLabel.textColor = 0x000000;
        freqLabel.x = 50;
        freqLabel.y = 600;
        
        frequencyText = new h2d.Text(font, s2d);
        frequencyText.textColor = 0x000000;
        frequencyText.x = 250;
        frequencyText.y = 600;
        
        // Bouton reset
        var resetButtonBg = new h2d.Graphics(s2d);
        resetButtonBg.beginFill(0x4CAF50);
        resetButtonBg.drawRoundedRect(50, 700, 150, 40, 5);
        resetButtonBg.endFill();
        
        var resetButton = new h2d.Interactive(150, 40, s2d);
        resetButton.x = 50;
        resetButton.y = 700;
        resetButton.onClick = function(_) {
            position1 = equilibriumPosition1;
            velocity1 = 0.0;
            position2 = position1 + equilibriumLength2;
            velocity2 = 0.0;
            historyPos1 = [];
            historyPos2 = [];
        };
        resetButton.onOver = function(_) {
            resetButtonBg.clear();
            resetButtonBg.beginFill(0x45a049);
            resetButtonBg.drawRoundedRect(50, 700, 150, 40, 5);
            resetButtonBg.endFill();
        };
        resetButton.onOut = function(_) {
            resetButtonBg.clear();
            resetButtonBg.beginFill(0x4CAF50);
            resetButtonBg.drawRoundedRect(50, 700, 150, 40, 5);
            resetButtonBg.endFill();
        };
        
        var resetText = new h2d.Text(font, s2d);
        resetText.text = "Réinitialiser";
        resetText.textColor = 0xFFFFFF;
        resetText.x = 70;
        resetText.y = 710;
        
        // Instructions
        var instructions = new h2d.Text(font, s2d);
        instructions.text = "Cliquez sur les masses pour les déplacer";
        instructions.textColor = 0x666666;
        instructions.x = 250;
        instructions.y = 710;
    }
    
    override function update(dt:Float) {
        // Limiter dt pour éviter l'instabilité
        if (dt > 0.05) dt = 0.05;
        
        // Récupérer les valeurs des sliders
        mass1 = mass1Slider.getValue();
        stiffness1 = stiffness1Slider.getValue();
        mass2 = mass2Slider.getValue();
        stiffness2 = stiffness2Slider.getValue();
        
        // Mise à jour des textes
        mass1Text.text = Std.string(Math.round(mass1 * 100) / 100);
        stiffness1Text.text = Std.string(Math.round(stiffness1 * 10) / 10);
        mass2Text.text = Std.string(Math.round(mass2 * 100) / 100);
        stiffness2Text.text = Std.string(Math.round(stiffness2 * 10) / 10);
        
        // Calculer et afficher les fréquences propres (approximation)
        var omega1 = Math.sqrt((stiffness1 + stiffness2) / mass1 + stiffness2 / mass2);
        var omega2 = Math.sqrt(stiffness1 / mass1);
        var freq1 = omega1 / (2 * Math.PI);
        var freq2 = omega2 / (2 * Math.PI);
        frequencyText.text = Std.string(Math.round(freq1 * 100) / 100) + " Hz, " + Std.string(Math.round(freq2 * 100) / 100) + " Hz";
        
        // Équations du mouvement pour système à 2 étages
        // m1 * a1 = -k1 * (x1 - x0) + k2 * (x2 - x1 - L2)
        // m2 * a2 = -k2 * (x2 - x1 - L2)
        // où L2 est la longueur au repos du ressort 2
        
        var displacement1 = position1 - equilibriumPosition1;
        var extension2 = (position2 - position1) - equilibriumLength2;
        
        var force1_from_spring1 = -stiffness1 * displacement1;
        var force1_from_spring2 = stiffness2 * extension2;
        var acceleration1 = (force1_from_spring1 + force1_from_spring2) / mass1;
        
        var force2_from_spring2 = -stiffness2 * extension2;
        var acceleration2 = force2_from_spring2 / mass2;
        
        // Intégration (méthode de Verlet semi-implicite)
        if (!isDragging || draggedMass != 1) {
            velocity1 += acceleration1 * dt;
            position1 += velocity1 * dt;
        }
        
        if (!isDragging || draggedMass != 2) {
            velocity2 += acceleration2 * dt;
            position2 += velocity2 * dt;
        }
        
        // Limiter la position pour que les masses ne traversent pas le sol
        if (position1 < 30) {
            position1 = 30;
            velocity1 = 0;
        }
        if (position2 < position1 + 30) {
            position2 = position1 + 30;
            velocity2 = 0;
        }
        
        // Interaction: déplacer les masses avec la souris
        var mouseX = s2d.mouseX;
        var mouseY = s2d.mouseY;
        var mass1X = centerX;
        var mass1Y = centerY - position1;
        var mass2X = centerX;
        var mass2Y = centerY - position2;
        
        if (hxd.Key.isDown(hxd.Key.MOUSE_LEFT)) {
            if (!isDragging) {
                // Vérifier quelle masse on clique
                var dx1 = mouseX - mass1X;
                var dy1 = mouseY - mass1Y;
                var dx2 = mouseX - mass2X;
                var dy2 = mouseY - mass2Y;
                
                // Priorité à la masse 2 si elle est plus proche
                if (dx2 * dx2 + dy2 * dy2 < 900) {
                    isDragging = true;
                    draggedMass = 2;
                } else if (dx1 * dx1 + dy1 * dy1 < 900) {
                    isDragging = true;
                    draggedMass = 1;
                }
            }
            
            if (isDragging) {
                if (draggedMass == 1) {
                    var newPos = centerY - mouseY;
                    if (newPos > 30) {
                        position1 = newPos;
                        velocity1 = 0;
                        // Déplacer aussi la masse 2 pour maintenir la distance relative
                        position2 = position1 + (position2 - position1);
                    }
                } else if (draggedMass == 2) {
                    var newPos = centerY - mouseY;
                    if (newPos > position1 + 30) {
                        position2 = newPos;
                        velocity2 = 0;
                    }
                }
            }
        } else {
            isDragging = false;
            draggedMass = 0;
        }
        
        // Ajouter les positions actuelles à l'historique
        historyPos1.push(position1);
        historyPos2.push(position2);
        
        // Limiter la taille de l'historique
        if (historyPos1.length > maxHistorySize) {
            historyPos1.shift();
        }
        if (historyPos2.length > maxHistorySize) {
            historyPos2.shift();
        }
        
        // Dessiner
        draw();
    }
    
    function draw() {
        graphics.clear();
        graphicsHistory.clear();
        
        // === TRACÉ DES COURBES ===
        var graphStartX = 50;
        var graphEndX = 250;
        var graphWidth = graphEndX - graphStartX;
        
        // Fond du graphique
        graphicsHistory.beginFill(0xF5F5F5);
        graphicsHistory.drawRect(graphStartX, 50, graphWidth, 350);
        graphicsHistory.endFill();
        
        // Bordure
        graphicsHistory.lineStyle(2, 0x000000, 0.3);
        graphicsHistory.drawRect(graphStartX, 50, graphWidth, 350);
        
        // Ligne de référence du sol (en bas du graphique)
        graphicsHistory.lineStyle(1, 0x8B4513, 0.5);
        graphicsHistory.moveTo(graphStartX, 400);
        graphicsHistory.lineTo(graphEndX, 400);
        
        // Tracé de la courbe de la masse 1
        if (historyPos1.length > 1) {
            graphicsHistory.lineStyle(2, 0xFF5722);
            for (i in 0...historyPos1.length) {
                var x = graphEndX - (historyPos1.length - i) * (graphWidth / maxHistorySize);
                var y = 400 - historyPos1[i] * 0.5; // 0.5 = facteur d'échelle
                
                if (i == 0) {
                    graphicsHistory.moveTo(x, y);
                } else {
                    graphicsHistory.lineTo(x, y);
                }
            }
        }
        
        // Tracé de la courbe de la masse 2
        if (historyPos2.length > 1) {
            graphicsHistory.lineStyle(2, 0xFFC107);
            for (i in 0...historyPos2.length) {
                var x = graphEndX - (historyPos2.length - i) * (graphWidth / maxHistorySize);
                var y = 400 - historyPos2[i] * 0.5; // 0.5 = facteur d'échelle
                
                if (i == 0) {
                    graphicsHistory.moveTo(x, y);
                } else {
                    graphicsHistory.lineTo(x, y);
                }
            }
        }
        
        // === SYSTÈME MASSE-RESSORT ===
        
        // Sol (ligne de base)
        graphics.lineStyle(3, 0x8B4513);
        graphics.moveTo(0, centerY);
        graphics.lineTo(800, centerY);
        
        // Hachures pour représenter le sol
        for (i in 0...20) {
            var x = i * 40;
            graphics.lineStyle(2, 0x8B4513);
            graphics.moveTo(x, centerY);
            graphics.lineTo(x + 20, centerY + 15);
        }
        
        // Point d'ancrage du ressort 1
        graphics.beginFill(0x333333);
        graphics.drawCircle(centerX, centerY, 8);
        graphics.endFill();
        
        // Positions des masses
        var mass1X = centerX;
        var mass1Y = centerY - position1;
        var mass2X = centerX;
        var mass2Y = centerY - position2;
        
        // Ressort 1 (du sol à la masse 1)
        graphics.lineStyle(2, 0x2196F3);
        drawSpring(centerX, centerY, mass1X, mass1Y);
        
        // Masse 1
        graphics.beginFill(0xFF5722);
        graphics.drawCircle(mass1X, mass1Y, 30);
        graphics.endFill();
        graphics.lineStyle(2, 0x000000, 0.3);
        graphics.drawCircle(mass1X, mass1Y, 30);
        
        // Ressort 2 (de la masse 1 à la masse 2)
        graphics.lineStyle(2, 0x4CAF50);
        drawSpring(mass1X, mass1Y, mass2X, mass2Y);
        
        // Masse 2
        graphics.beginFill(0xFFC107);
        graphics.drawCircle(mass2X, mass2Y, 30);
        graphics.endFill();
        graphics.lineStyle(2, 0x000000, 0.3);
        graphics.drawCircle(mass2X, mass2Y, 30);
        
        // Ligne de référence (position d'équilibre masse 1)
        graphics.lineStyle(1, 0xFF5722, 0.3);
        graphics.moveTo(centerX - 100, centerY - equilibriumPosition1);
        graphics.lineTo(centerX + 100, centerY - equilibriumPosition1);
        
        // Ligne de référence (position d'équilibre masse 2)
        graphics.lineStyle(1, 0xFFC107, 0.3);
        var equilibriumY2 = centerY - equilibriumPosition1 - equilibriumLength2;
        graphics.moveTo(centerX - 100, equilibriumY2);
        graphics.lineTo(centerX + 100, equilibriumY2);
    }
    
    function drawSpring(x1:Float, y1:Float, x2:Float, y2:Float) {
        var segments = 20;
        var amplitude = 15;
        
        var dx = x2 - x1;
        var dy = y2 - y1;
        var length = Math.sqrt(dx * dx + dy * dy);
        
        if (length < 1) return;
        
        var ux = dx / length;
        var uy = dy / length;
        var perpX = -uy;
        var perpY = ux;
        
        graphics.moveTo(x1, y1);
        
        for (i in 0...segments + 1) {
            var t = i / segments;
            var offset = (i % 2 == 0) ? amplitude : -amplitude;
            if (i == 0 || i == segments) offset = 0;
            
            var x = x1 + dx * t + perpX * offset;
            var y = y1 + dy * t + perpY * offset;
            graphics.lineTo(x, y);
        }
    }
    
    static function main() {
        new Main();
    }
}

// Classe Slider simple
class Slider {
    var graphics:h2d.Graphics;
    var interactive:h2d.Interactive;
    var scene:h2d.Scene;
    var x:Float;
    var y:Float;
    var width:Float;
    var min:Float;
    var max:Float;
    var value:Float;
    var isDragging:Bool = false;
    
    public function new(parent:h2d.Object, x:Float, y:Float, width:Float, min:Float, max:Float, initialValue:Float) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.min = min;
        this.max = max;
        this.value = initialValue;
        this.scene = cast(parent, h2d.Scene);
        
        graphics = new h2d.Graphics(parent);
        interactive = new h2d.Interactive(width, 20, parent);
        interactive.x = x;
        interactive.y = y - 10;
        
        interactive.onPush = function(_) {
            isDragging = true;
            updateValue(scene.mouseX);
        };
        
        interactive.onRelease = function(_) {
            isDragging = false;
        };
        
        interactive.onMove = function(_) {
            if (isDragging) {
                updateValue(scene.mouseX);
            }
        };
        
        draw();
    }
    
    function updateValue(mouseX:Float) {
        var localX = mouseX - x;
        localX = Math.max(0, Math.min(width, localX));
        var t = localX / width;
        value = min + (max - min) * t;
        draw();
    }
    
    function draw() {
        graphics.clear();
        
        // Barre de fond
        graphics.beginFill(0xCCCCCC);
        graphics.drawRect(x, y - 2, width, 4);
        graphics.endFill();
        
        // Curseur
        var cursorX = x + ((value - min) / (max - min)) * width;
        graphics.beginFill(0x2196F3);
        graphics.drawCircle(cursorX, y, 8);
        graphics.endFill();
    }
    
    public function getValue():Float {
        return value;
    }
}
