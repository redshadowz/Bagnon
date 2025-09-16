-- Slash Commands
BAGNON_COMMAND_HELP = "help"
BAGNON_COMMAND_SHOWBAGS = "bags"
BAGNON_COMMAND_SHOWBANK = "bank"
BAGNON_COMMAND_REVERSE = "reverse"
BAGNON_COMMAND_OVERRIDE_BANK = "overridebank"
BAGNON_COMMAND_TOGGLE_TOOLTIPS = "tooltips"
BAGNON_COMMAND_DEBUG_ON = "debug"
BAGNON_COMMAND_DEBUG_OFF = "nodebug"

-- /bgn help
BAGNON_HELP_TITLE = "Bagnon commands:"
BAGNON_HELP_SHOWBAGS = "/bgn " .. BAGNON_COMMAND_SHOWBAGS .. " - Show/Hide Bagnon."
BAGNON_HELP_SHOWBANK = "/bgn " .. BAGNON_COMMAND_SHOWBANK .. " - Show/Hide Banknon."
BAGNON_HELP_HELP = "/bgn " .. BAGNON_COMMAND_HELP .. " - Display slash commands."

--/bgn debug
BAGNON_DEBUG_ENABLED = "Debugging mode enabled."

--/bgn nodebug
BAGNON_DEBUG_DISABLED = "Debugging mode disabled."

-- System Messages
BAGNON_INITIALIZED = "Bagnon initialized.  Type /bagnon or /bgn for commands"
BAGNON_UPDATED = "Bagnon Settings updated to v%s.  Type /bagnon or /bgn for commands"

--Titles
BAGNON_INVENTORY_TITLE = "%s's Inventory"
BAGNON_BANK_TITLE = "%s's Bank"

--Bag Button
BAGNON_SHOWBAGS = "Show Bags"
BAGNON_HIDEBAGS = "Hide Bags"

--General Options Menu
BAGNON_MAINOPTIONS_TITLE = "Bagnon Options"
BAGNON_MAINOPTIONS_SHOW = "Show"

--Right Click Menu
BAGNON_OPTIONS_TITLE = "%s Settings"
BAGNON_OPTIONS_LOCK = "Lock Position"
BAGNON_OPTIONS_BACKGROUND = "Background"
BAGNON_OPTIONS_REVERSE = "Reverse Bag Ordering"
BAGNON_OPTIONS_COLUMNS = "Columns"
BAGNON_OPTIONS_SPACING = "Spacing"
BAGNON_OPTIONS_SCALE = "Scale"
BAGNON_OPTIONS_OPACITY = "Opacity"
BAGNON_OPTIONS_STRATA = "Layer"
BAGNON_OPTIONS_STAY_ON_SCREEN = "Stay on Screen"

-- Tooltips
BAGNON_TITLE_TOOLTIP = "<Right-Click> to open up the settings menu."

--Bag Tooltips
BAGNON_BAGS_HIDE = "<Shift-Click> to hide."
BAGNON_BAGS_SHOW = "<Shift-Click> to show."

--Search Tooltip
BAGNON_SPOT_TOOLTIP = "<Double-Click> to search."

-- Other
BAGNON_ITEMTYPE_CONTAINER = "Container"
BAGNON_ITEMTYPE_QUIVER = "Quiver"
BAGNON_SUBTYPE_SOULBAG = "Soul Bag"
BAGNON_SUBTYPE_BAG = "Bag"

-- English
BAGNON_MAINOPTIONS_SHOW_BANK = "At Bank";
BAGNON_MAINOPTIONS_SHOW_VENDOR = "At Vendor";
BAGNON_MAINOPTIONS_SHOW_AH = "At Auction House";
BAGNON_MAINOPTIONS_SHOW_MAILBOX = "At Mailbox";
BAGNON_MAINOPTIONS_SHOW_TRADING = "When Trading";
BAGNON_MAINOPTIONS_SHOW_CRAFTING = "When Crafting";

BAGNON_MAINOPTIONS_SHOW_TOOLTIPS = "Show Tooltips";
BAGNON_MAINOPTIONS_SHOW_FOREVERTOOLTIPS = "Show Detailed Tooltips";
BAGNON_MAINOPTIONS_SHOW_BORDERS = "Show Item Quality Borders";

-- Bagnon Forever
BAGNON_FOREVER_VERSION = "6.6.30"
BAGNON_FOREVER_COMMAND_DELETE_CHARACTER = "delete"
BAGNON_FOREVER_HELP_DELETE_CHARACTER = "/bgn "..BAGNON_FOREVER_COMMAND_DELETE_CHARACTER.." <character> <realm> - Removes the given character's inventory and bank data."
BAGNON_FOREVER_CHARACTER_DELETED = "Removed inventory data about %s of %s."
BAGNON_FOREVER_UPDATED = "Bagnon Forever data updated to v"..BAGNON_FOREVER_VERSION.."."
BAGNON_FOREVER_HAS = "has"
BAGNON_FOREVER_BAGS = "(Bags)"
BAGNON_FOREVER_BANK = "(Bank)"
BAGNON_FOREVER_MONEY_ON_REALM = "Total On %s"

if GetLocale() == "zhCN" then -- Chinese
	BAGNON_MAINOPTIONS_TITLE = "Bagnon 设置";
	BAGNON_MAINOPTIONS_SHOW = "显示";
	BAGNON_MAINOPTIONS_SHOW_BANK = "在银行时";
	BAGNON_MAINOPTIONS_SHOW_VENDOR = "与商贩对话时";
	BAGNON_MAINOPTIONS_SHOW_AH = "在拍卖行时";
	BAGNON_MAINOPTIONS_SHOW_MAILBOX = "打开邮箱时";
	BAGNON_MAINOPTIONS_SHOW_TRADING = "交易时";
	BAGNON_MAINOPTIONS_SHOW_CRAFTING = "制作物品时";
	BAGNON_MAINOPTIONS_SHOW_TOOLTIPS = "显示提示";
	BAGNON_MAINOPTIONS_SHOW_FOREVERTOOLTIPS = "显示详细信息";
	BAGNON_MAINOPTIONS_SHOW_BORDERS = "显示物品质量框";
	BAGNON_COMMAND_HELP = "help"
	BAGNON_COMMAND_SHOWBAGS = "bags"
	BAGNON_COMMAND_SHOWBANK = "bank"
	BAGNON_COMMAND_REVERSE = "reverse"
	BAGNON_COMMAND_OVERRIDE_BANK = "overridebank"
	BAGNON_COMMAND_TOGGLE_TOOLTIPS = "tooltips"
	BAGNON_COMMAND_DEBUG_ON = "debug"
	BAGNON_COMMAND_DEBUG_OFF = "nodebug"
	BAGNON_HELP_TITLE = "Bagnon 指令："
	BAGNON_HELP_SHOWBAGS = "/bgn " .. BAGNON_COMMAND_SHOWBAGS .. " - 显示/隐藏 Bagnon"
	BAGNON_HELP_SHOWBANK = "/bgn " .. BAGNON_COMMAND_SHOWBANK .. " - 显示/隐藏 Banknon"
	BAGNON_HELP_HELP = "/bgn " .. BAGNON_COMMAND_HELP .. " - 显示其它指令"
	BAGNON_DEBUG_ENABLED = "Debug 模式开启。"
	BAGNON_DEBUG_DISABLED = "Debug 模式关闭。"
	BAGNON_INITIALIZED = "Bagnon 已加载。输入 /bagnon 或 /bgn 查询指令"
	BAGNON_UPDATED = "Bagnon 已更新至 v%s 。输入 /bagnon 或 /bgn 查询指令"
	BAGNON_INVENTORY_TITLE = "%s的背包"
	BAGNON_BANK_TITLE = "%s的银行"
	BAGNON_SHOWBAGS = "显示包裹"
	BAGNON_HIDEBAGS = "隐藏包裹"
	BAGNON_OPTIONS_TITLE = "%s 设置"
	BAGNON_OPTIONS_LOCK = "锁定位置"
	BAGNON_OPTIONS_BACKGROUND = "背景颜色"
	BAGNON_OPTIONS_REVERSE = "反向排列"
	BAGNON_OPTIONS_COLUMNS = "列数"
	BAGNON_OPTIONS_SPACING = "间距"
	BAGNON_OPTIONS_SCALE = "缩放"
	BAGNON_OPTIONS_OPACITY = "透明度"
	BAGNON_OPTIONS_STRATA = "层"
	BAGNON_OPTIONS_STAY_ON_SCREEN = "保持显示"
	BAGNON_TITLE_TOOLTIP = "<右键点击>打开设置菜单"
	BAGNON_BAGS_HIDE = "<Shift-单击>隐藏"
	BAGNON_BAGS_SHOW = "<Shift-单击>显示"
	BAGNON_SPOT_TOOLTIP = "<双击>进行搜索"
	BAGNON_ITEMTYPE_CONTAINER = "容器"
	BAGNON_ITEMTYPE_QUIVER = "箭袋"
	BAGNON_SUBTYPE_SOULBAG = "灵魂袋"
	BAGNON_SUBTYPE_BAG = "袋"

	BAGNON_FOREVER_COMMAND_DELETE_CHARACTER = "delete"
	BAGNON_FOREVER_HELP_DELETE_CHARACTER = "/bgn "..BAGNON_FOREVER_COMMAND_DELETE_CHARACTER.." <角色> <服务器> - 删除该角色的背包和银行数据。"
	BAGNON_FOREVER_CHARACTER_DELETED = "删除%s(%s)的背包数据。"
	BAGNON_FOREVER_UPDATED = "Bagnon Forever 数据更新至 v" .. BAGNON_FOREVER_VERSION .. "。"
	BAGNON_FOREVER_HAS = "有"
	BAGNON_FOREVER_BAGS = "件(背包中)"
	BAGNON_FOREVER_BANK = "件(银行中)"
	BAGNON_FOREVER_MONEY_ON_REALM = "%s服务器上的总资产"
elseif GetLocale() == "zhTW" then
	BAGNON_ITEMTYPE_CONTAINER = "容器";
	BAGNON_SUBTYPE_SOULBAG = "靈魂碎片背包";
	BAGNON_SUBTYPE_BAG = "容器";
elseif GetLocale() == "deDE" then -- German
	BAGNON_MAINOPTIONS_SHOW = "Zeige";
	BAGNON_HELP_TITLE = "Bagnon Kommandos:";
	BAGNON_HELP_SHOWBAGS = "/bgn " .. BAGNON_COMMAND_SHOWBAGS .. " - Zeige/Verstecke Bagnon.";
	BAGNON_HELP_SHOWBANK = "/bgn " .. BAGNON_COMMAND_SHOWBANK .. " - Zeige/Verstecke Banknon.";
	BAGNON_HELP_HELP = "/bgn " .. BAGNON_COMMAND_HELP .. " - Zeige Slash Kommandos.";
	BAGNON_INITIALIZED = "Bagnon inizialisiert. Bitte /bagnon oder /bgn f\195\188r Kommandos";
	BAGNON_UPDATED = "Bagnon Einstellungen aktualisiert auf v%s. Bitte /bagnon oder /bgn f\195\188r Kommandos";
	BAGNON_INVENTORY_TITLE = "%s's Inventar";
	BAGNON_BANK_TITLE = "%s's Bank";
	BAGNON_SHOWBAGS = "+ Taschen";
	BAGNON_HIDEBAGS = "- Taschen";
	BAGNON_OPTIONS_TITLE = "%s Einstellungen";
	BAGNON_OPTIONS_LOCK = "Fixiere Position";
	BAGNON_OPTIONS_BACKGROUND = "Hintergrund";
	BAGNON_OPTIONS_REVERSE = "Drehe Taschenanordnung um";
	BAGNON_OPTIONS_COLUMNS = "Spalte";
	BAGNON_OPTIONS_SPACING = "Abstand";
	BAGNON_OPTIONS_SCALE = "Masstab";
	BAGNON_OPTIONS_OPACITY = "Transparenz";
	BAGNON_OPTIONS_STRATA = "Layer";
	BAGNON_TITLE_TOOLTIP = "<Rechts-Klick> Um Einstellungs Men\195\188 zu zeigen";
	BAGNON_BAGS_HIDE = "<Shift-Klick> zum verstecken.";
	BAGNON_BAGS_SHOW = "<Shift-Klick> zum zeigen.";
	BAGNON_ITEMTYPE_CONTAINER = "Beh\195\164lter";
	BAGNON_ITEMTYPE_QUIVER = "K\195\182cher";
	BAGNON_SUBTYPE_SOULBAG = "Seelentasche";
	BAGNON_SUBTYPE_BAG = "Beh\195\164lter";
elseif GetLocale() == "esES" then -- Spanish
	BAGNON_MAINOPTIONS_TITLE = "Opciones de Bagnon";
	BAGNON_MAINOPTIONS_SHOW = "Mostrar";
	BAGNON_MAINOPTIONS_SHOW_BANK = "En el Banco";
	BAGNON_MAINOPTIONS_SHOW_VENDOR = "En los Vendedores";
	BAGNON_MAINOPTIONS_SHOW_AH = "En Casa de Subastas";
	BAGNON_MAINOPTIONS_SHOW_MAILBOX = "En el Correo";
	BAGNON_MAINOPTIONS_SHOW_TRADING = "Comerciando";
	BAGNON_MAINOPTIONS_SHOW_CRAFTING = "Fabricando";
	BAGNON_MAINOPTIONS_SHOW_TOOLTIPS = "Mostrar ayudas";
	BAGNON_MAINOPTIONS_SHOW_FOREVERTOOLTIPS = "Mostrar ayuda detallada";
	BAGNON_MAINOPTIONS_SHOW_BORDERS = "Resaltar calidad de objetos";
	BAGNON_COMMAND_HELP = "help"
	BAGNON_COMMAND_SHOWBAGS = "bags"
	BAGNON_COMMAND_SHOWBANK = "bank"
	BAGNON_COMMAND_REVERSE = "reverse"
	BAGNON_COMMAND_OVERRIDE_BANK = "overridebank"
	BAGNON_COMMAND_TOGGLE_TOOLTIPS = "tooltips"
	BAGNON_COMMAND_DEBUG_ON = "debug"
	BAGNON_COMMAND_DEBUG_OFF = "nodebug"
	BAGNON_HELP_TITLE = "Bagnon commands:"
	BAGNON_HELP_SHOWBAGS = "/bgn " .. BAGNON_COMMAND_SHOWBAGS .. " - Muestra/Oculta Bagnon."
	BAGNON_HELP_SHOWBANK = "/bgn " .. BAGNON_COMMAND_SHOWBANK .. " - Muestra/Oculta Banknon."
	BAGNON_HELP_HELP = "/bgn " .. BAGNON_COMMAND_HELP .. " - Mostrar commandos."
	BAGNON_DEBUG_ENABLED = "Modo depuración activo."
	BAGNON_DEBUG_DISABLED = "Modo depuración inactivo."
	BAGNON_INITIALIZED = "Bagnon inicializado. Teclee /bagnon o /bgn para los comandos"
	BAGNON_UPDATED = "Opciones de Bagnon actualizadas a v%s. Teclee /bagnon o /bgn para los comandos"
	BAGNON_INVENTORY_TITLE = "Inventario de %s"
	BAGNON_BANK_TITLE = "Banco de %s"
	BAGNON_SHOWBAGS = "Mostrar Bolsas"
	BAGNON_HIDEBAGS = "Ocultar Bolsas"
	BAGNON_OPTIONS_TITLE = "Opciones de %s"
	BAGNON_OPTIONS_LOCK = "Bloquear posición"
	BAGNON_OPTIONS_BACKGROUND = "Fondo"
	BAGNON_OPTIONS_REVERSE = "Ordenar las bolsas inversamente"
	BAGNON_OPTIONS_COLUMNS = "Columnas"
	BAGNON_OPTIONS_SPACING = "Espaciado"
	BAGNON_OPTIONS_SCALE = "Escala"
	BAGNON_OPTIONS_OPACITY = "Opacidad"
	BAGNON_OPTIONS_STRATA = "Capa"
	BAGNON_OPTIONS_STAY_ON_SCREEN = "Permanecer en pantalla"
	BAGNON_TITLE_TOOLTIP = "<Botón DER> para menú de opciones."
	BAGNON_BAGS_HIDE = "<Mayusculas + Botón IZQ> para esconder."
	BAGNON_BAGS_SHOW = "<Mayusculas + Botón IZQ> para mostrar."
	BAGNON_SPOT_TOOLTIP = "<Doble-Click> para buscar."
	BAGNON_ITEMTYPE_CONTAINER = "Contenedor"
	BAGNON_ITEMTYPE_QUIVER = "Carcaj"
	BAGNON_SUBTYPE_SOULBAG = "Bolsa de Gemas"
	BAGNON_SUBTYPE_BAG = "Bolsa"

	BAGNON_FOREVER_COMMAND_DELETE_CHARACTER = "delete"
	BAGNON_FOREVER_HELP_DELETE_CHARACTER = "/bgn "..BAGNON_FOREVER_COMMAND_DELETE_CHARACTER.." <character> <realm> - Elimina los datos del inventario y del banco del personaje ."
	BAGNON_FOREVER_CHARACTER_DELETED = "Elimina los datos de %s de %s."
	BAGNON_FOREVER_UPDATED = "Opciones de Bagnon Forever actualizadas a v" .. BAGNON_FOREVER_VERSION .. "."
	BAGNON_FOREVER_MONEY_ON_REALM = "Dinero total de %s"
elseif GetLocale() == "frFR" then -- French
	BAGNON_MAINOPTIONS_TITLE = "Bagnon Options";
	BAGNON_MAINOPTIONS_SHOW = "Montrer";
	BAGNON_MAINOPTIONS_SHOW_BANK = "A la Banque";
	BAGNON_MAINOPTIONS_SHOW_VENDOR = "Chez un Vendeur";
	BAGNON_MAINOPTIONS_SHOW_AH = "A l\'hotel des ventes";
	BAGNON_MAINOPTIONS_SHOW_MAILBOX = "A la Boite au Lettre";
	BAGNON_MAINOPTIONS_SHOW_TRADING = "Quand échange";
	BAGNON_MAINOPTIONS_SHOW_CRAFTING = "Quand M\195\169tier";
	BAGNON_MAINOPTIONS_SHOW_TOOLTIPS = "Afficher les bulles d'aide";
	BAGNON_MAINOPTIONS_SHOW_BORDERS = "Colorer le bord selon la qualit\195\169 de l\'objet";
	BAGNON_COMMAND_HELP = "help";
	BAGNON_COMMAND_SHOWBAGS = "bags";
	BAGNON_COMMAND_SHOWBANK = "bank";
	BAGNON_COMMAND_REVERSE = "reverse";
	BAGNON_COMMAND_OVERRIDE_BANK = "overridebank";
	BAGNON_COMMAND_TOGGLE_TOOLTIPS = "tooltips";
	BAGNON_COMMAND_DEBUG_ON = "debug";
	BAGNON_COMMAND_DEBUG_OFF = "nodebug";
	BAGNON_HELP_TITLE = "Bagnon commandes:";
	BAGNON_HELP_SHOWBAGS = "/bgn " .. BAGNON_COMMAND_SHOWBAGS .. " - Montrer/Cacher Bagnon.";
	BAGNON_HELP_SHOWBANK = "/bgn " .. BAGNON_COMMAND_SHOWBANK .. " - Montrer/Cacher Banknon.";
	BAGNON_HELP_HELP = "/bgn " .. BAGNON_COMMAND_HELP .. " - Afficher slash commandes.";
	BAGNON_DEBUG_ENABLED = "Debugging mode enabled.";
	BAGNON_DEBUG_DISABLED = "Debugging mode disabled.";
	BAGNON_INITIALIZED = "Bagnon charg\195\169.  Taper /bagnon ou /bgn pour les commandes";
	BAGNON_UPDATED = "Bagnon  Configs \195\160 jour v%s.  Taper /bagnon ou /bgn pour les commandes";
	BAGNON_INVENTORY_TITLE = "Sac de %s";
	BAGNON_BANK_TITLE = "Banque de %s";
	BAGNON_SHOWBAGS = "Montrer Sacs";
	BAGNON_HIDEBAGS = "Cacher Sacs";
	BAGNON_OPTIONS_TITLE = "Config de %s";
	BAGNON_OPTIONS_LOCK = "Verrouiller Position";
	BAGNON_OPTIONS_BACKGROUND = "Fond";
	BAGNON_OPTIONS_REVERSE = "Inverser l\'ordre dans le Sac";
	BAGNON_OPTIONS_COLUMNS = "Colonne";
	BAGNON_OPTIONS_SPACING = "Espace";
	BAGNON_OPTIONS_SCALE = "Echelle";
	BAGNON_OPTIONS_OPACITY = "Opacit\195\169";
	BAGNON_OPTIONS_STRATA = "Couche";
	BAGNON_OPTIONS_STAY_ON_SCREEN = "Rester \195\160 l\'Ecran";
	BAGNON_TITLE_TOOLTIP = "<Clic-Droit> pour ouvrir le  menu de Config.";
	BAGNON_BAGS_HIDE = "<Maj-Clic> pour cacher.";
	BAGNON_BAGS_SHOW = "<Maj-Clic> pour montrer.";
	BAGNON_ITEMTYPE_CONTAINER = "Récipient";
	BAGNON_ITEMTYPE_QUIVER = "Quiver (?)";
	BAGNON_SUBTYPE_SOULBAG = "Sac d\'\195\162me";
	BAGNON_SUBTYPE_BAG = "Sac";

	BAGNON_FOREVER_COMMAND_DELETE_CHARACTER = "delete"
	BAGNON_FOREVER_HELP_DELETE_CHARACTER = "/bgn "..BAGNON_FOREVER_COMMAND_DELETE_CHARACTER.." <character> <realm> - Supprime les donn\195\169s des sacs et la banque du personnage ."
	BAGNON_FOREVER_CHARACTER_DELETED = "Supprime les donn\195\169s des sacs de %s de %s."
	BAGNON_FOREVER_UPDATED = "Bagnon Forever donn\195\169s \195\160 jour v" .. BAGNON_FOREVER_VERSION .. "."
	BAGNON_FOREVER_MONEY_ON_REALM = "Total d\'argent de %s"
end
