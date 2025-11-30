<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache"/>
<meta HTTP-EQUIV="Expires" CONTENT="-1"/>
<link rel="shortcut icon" href="images/favicon.png"/>
<link rel="icon" href="images/favicon.png"/>
<title>软件中心-Softether VPN server</title>
<link rel="stylesheet" type="text/css" href="index_style.css"/>
<link rel="stylesheet" type="text/css" href="form_style.css"/>
<link rel="stylesheet" type="text/css" href="usp_style.css"/>
<link rel="stylesheet" type="text/css" href="ParentalControl.css">
<link rel="stylesheet" type="text/css" href="css/icon.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="res/softcenter.css">
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>

<style type="text/css">
.contentM_qis {
	position: fixed;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius:10px;
	z-index: 10;
	background-color:#2B373B;
	/*margin-left: -100px;*/
	top: 100px;
	width:755px;
	return height:auto;
	box-shadow: 3px 3px 10px #000;
	background: rgba(0,0,0,0.85);
	display:none;
}
.user_title{
	text-align:center;
	font-size:18px;
	color:#99FF00;
	padding:10px;
	font-weight:bold;
}
</style>
<script>
var db_softether = {}
function init() {
	show_menu();
	get_dbus_data();
	get_status();
	dataPost("log_lnk");
}
function get_status(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "softether_status.sh", "params":[1], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			if(response.result){
				E("status").innerHTML = response.result;
				setTimeout("get_status();", 5000);
			}
		},
		error: function(xhr){
			console.log(xhr)
			setTimeout("get_status();", 15000);
		}
	});
}
function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "/_api/softether",
		dataType: "json",
		async: false,
		success: function(data) {
			db_softether = data.result[0];

			E("softether_enable").checked = db_softether["softether_enable"] == "1";
			E("softether_tcp_v6").checked = db_softether["softether_tcp_v6"] == "1";
			E("softether_udp_v6").checked = db_softether["softether_udp_v6"] == "1";
			E("softether_foreground").checked = db_softether["softether_foreground"] == "1";
			E("softether_conf_fix").checked = db_softether["softether_conf_fix"] == "1";
			if(db_softether["softether_tcp_ports"]){
				E("softether_tcp_ports").value = db_softether["softether_tcp_ports"];
			}
			if(db_softether["softether_udp_ports"]){
				E("softether_udp_ports").value = db_softether["softether_udp_ports"];
			}
			if(db_softether["softether_lang"]){
				E("softether_lang").value = db_softether["softether_lang"];
			}
			if(db_softether["softether_DisableJsonRpcWebApi"]){
				E("softether_DisableJsonRpcWebApi").value = db_softether["softether_DisableJsonRpcWebApi"];
			}
			if(db_softether["softether_AutoSaveConfigSpan"]){
				E("softether_AutoSaveConfigSpan").value = db_softether["softether_AutoSaveConfigSpan"];
			}
			if(db_softether["softether_watch_time"]){
				E("softether_watch_time").value = db_softether["softether_watch_time"];
			}
			//TMP模式开始
			E("softether_conf_TMP").checked = db_softether["softether_conf_TMP"] == "1";
			if(db_softether["softether_conf_cron_time"]){
				E("softether_conf_cron_time").value = db_softether["softether_conf_cron_time"];
			}
			if(db_softether["softether_conf_cron_time2"]){
				E("softether_conf_cron_time2").value = db_softether["softether_conf_cron_time2"];
			}
			if(db_softether["softether_conf_cron_type"]){
				E("softether_conf_cron_type").value = db_softether["softether_conf_cron_type"];
			}
			//TMP模式结束
			update_visibility();
		}
	});
}
function menu_hook(title, tab) {
	tabtitle[tabtitle.length - 1] = new Array("", "软件中心", "离线安装", "Softether VPN server");
	tablink[tabtitle.length - 1] = new Array("", "Main_Soft_center.asp", "Main_Soft_setting.asp", "Module_softether.asp");
}

function dataPost(mark) {
	var uid = parseInt(Math.random() * 100000000);
	var postData = {"id": uid, "method": "softether_config.sh", "params": [mark], "fields": db_softether };
	$.ajax({
		url: "/_api/",
		cache: false,
		type: "POST",
		dataType: "json",
		data: JSON.stringify(postData),
		success: function(response) {
			if (response.result == uid){
				if (mark == "web_submit"){
					refreshpage();
				}
			}
		}
	});
}

function onSubmitCtrl() {
	showLoading(3);
// 	refreshpage(3);
	// collect data from checkbox
	db_softether["softether_enable"] = E("softether_enable").checked ? '1' : '0';
	db_softether["softether_tcp_v6"] = E("softether_tcp_v6").checked ? '1' : '0';
	db_softether["softether_udp_v6"] = E("softether_udp_v6").checked ? '1' : '0';
	db_softether["softether_foreground"] = E("softether_foreground").checked ? '1' : '0';
	db_softether["softether_conf_fix"] = E("softether_conf_fix").checked ? '1' : '0';
	db_softether["softether_lang"] = E("softether_lang").value;
	db_softether["softether_tcp_ports"] = E("softether_tcp_ports").value;
	db_softether["softether_udp_ports"] = E("softether_udp_ports").value;
	db_softether["softether_DisableJsonRpcWebApi"] = E("softether_DisableJsonRpcWebApi").value;
	db_softether["softether_AutoSaveConfigSpan"] = E("softether_AutoSaveConfigSpan").value;
	db_softether["softether_watch_time"] = E("softether_watch_time").value;
	
	//TMP模式开始
	db_softether["softether_conf_TMP"] = E("softether_conf_TMP").checked ? '1' : '0';
	if (!E("softether_conf_TMP").checked) {
		E("softether_conf_cron_type").value = "";
		E("softether_conf_cron_time").value = "";
		E("softether_conf_cron_time2").value = "";
	}
	if(!E("softether_conf_cron_type").value){
		E("softether_conf_cron_time").value = "";
		E("softether_conf_cron_time2").value = "";
	}else if(E("softether_conf_cron_type").value == "day"){
		E("softether_conf_cron_time2").value = "";
	}else if(E("softether_conf_cron_type").value == "hour"){
		E("softether_conf_cron_time").value = "";
	}
	db_softether["softether_conf_cron_time"] = E("softether_conf_cron_time").value;
	db_softether["softether_conf_cron_time2"] = E("softether_conf_cron_time2").value;
	db_softether["softether_conf_cron_type"] = E("softether_conf_cron_type").value;
	//TMP模式结束

	// post data
	dataPost("web_submit");
}
//操作表单时更新显示状态
function show_hide_element(){
	if(E("softether_conf_fix").checked){
		E("lang_tr").style.display = "";
		E("DisableJsonRpcWebApi_tr").style.display = "";
		E("AutoSaveConfigSpan_tr").style.display = "";
		E("mod_conf_bt").style.display = "";
	}else{
		E("lang_tr").style.display = "none";
		E("DisableJsonRpcWebApi_tr").style.display = "none";
		E("AutoSaveConfigSpan_tr").style.display = "none";
		E("mod_conf_bt").style.display = "none";
		}

	//TMP模式开始
	if(E("softether_conf_TMP").checked){
		E("softether_conf_TMP_txt").style.display = "";
	}else{
		E("softether_conf_TMP_txt").style.display = "none";
		}
	if(!E("softether_conf_cron_type").value){
		E("softether_conf_cron_time").style.display = "none";
		E("softether_conf_cron_time2").style.display = "none";
	}else if(E("softether_conf_cron_type").value == "day") {
		E("softether_conf_cron_time").style.display = "";
		E("softether_conf_cron_time2").style.display = "none";
	}else if(E("softether_conf_cron_type").value == "hour") {
		E("softether_conf_cron_time").style.display = "none";
		E("softether_conf_cron_time2").style.display = "";
	}
	//TMP模式结束
}
//刷新网页时更新显示状态
function update_visibility(){
	if(db_softether["softether_conf_fix"] == "1"){
		E("lang_tr").style.display = "";
		E("DisableJsonRpcWebApi_tr").style.display = "";
		E("AutoSaveConfigSpan_tr").style.display = "";
		E("mod_conf_bt").style.display = "";
	}else{
		E("lang_tr").style.display = "none";
		E("DisableJsonRpcWebApi_tr").style.display = "none";
		E("AutoSaveConfigSpan_tr").style.display = "none";
		E("mod_conf_bt").style.display = "none";
	}
	
	//TMP模式开始
	if(db_softether["softether_conf_TMP"] == "1"){
		E("softether_conf_TMP_txt").style.display = "";
	}else{
		E("softether_conf_TMP_txt").style.display = "none";
	}
	if(!db_softether["softether_conf_cron_type"]){
		E("softether_conf_cron_time").style.display = "none";
		E("softether_conf_cron_time2").style.display = "none";
	}else if(db_softether["softether_conf_cron_type"] == "day") {
		E("softether_conf_cron_time").style.display = "";
		E("softether_conf_cron_time2").style.display = "none";
	}else if(db_softether["softether_conf_cron_type"] == "hour") {
		E("softether_conf_cron_time").style.display = "none";
		E("softether_conf_cron_time2").style.display = "";
	}
	//TMP模式结束
}
//TMP模式备份按钮
function backupConf_do(){
	dataPost("record");
	E('backup_info').style.display = ""; 
	E("backup_info").innerHTML = "已完成";
}
function backupConf(){
	if(db_softether["softether_enable"] != "1" || db_softether["softether_conf_TMP"] != "1"){
		E("backup_info").innerHTML = "失败！服务未启动。";
		E('backup_info').style.display = "";
		return false;
	}
	E("backup_info").innerHTML = "处理中";
	E('backup_info').style.display = "";
	setTimeout("backupConf_do();", 2000);
}
//手动修改配置按钮
function mod_conf_do(){
	dataPost("modconf");
	E('mod_info').style.display = ""; 
	E("mod_info").innerHTML = "已完成";
}
function mod_conf(){
	if(db_softether["softether_enable"] == "1"){
		E("mod_info").innerHTML = "失败！服务启用时无法手动修改。可通过“提交”按钮重启服务自动修改。";
		E('mod_info').style.display = "";
		return false;
	}
	db_softether["softether_DisableJsonRpcWebApi"] = E("softether_DisableJsonRpcWebApi").value;
	db_softether["softether_AutoSaveConfigSpan"] = E("softether_AutoSaveConfigSpan").value;
	db_softether["softether_lang"] = E("softether_lang").value;

	E("mod_info").innerHTML = "处理中。。";
	E('mod_info').style.display = "";
	setTimeout("mod_conf_do();", 2000);
}
//读取日志 
function get_log(){
   $.ajax({
		url: '/_temp/softether_server_log.lnk',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			if (res.length == 0){
			E("logtxt").value = "（空链接，非前台模式尝试检查运行目录空间，修改配置文件的 AutoDeletCheckDiskFreeSpaceMin 项目）"; 
			} else {
			$('#logtxt').val(res);
			}
		}
	}); 
}

function open_file(open_file) {
	if (open_file == "log") {
	get_log();
}
	$("#" + open_file).fadeIn(200);
}
function close_file(close_file) {
	$("#" + close_file).fadeOut(200);
}

function open_hint(itemNum) {
	statusmenu = "";
	width = "350px";
	if (itemNum == 1) {
		statusmenu = "&nbsp;&nbsp;1. 此处显示程序在路由器后台是否运行，详细运行日志可以点击顶部的<b>服务器日志</b>查看。<br/>"
		statusmenu += "&nbsp;&nbsp;2. 当出现<b>获取中...</b>或者<b>一串混乱数字</b>时，可能是路由器后台登陆超时或者httpd进程崩溃导致，如果是后者，请等待路由器httpd进程恢复，或者自行使用ssh命令：service restart_httpd重启httpd。"
		_caption = "运行状态";
	}
	if (itemNum == 2) {
		statusmenu = "&nbsp;&nbsp;1. DE版有效，输出至控制台而不是文件（不生成日志）。<br/>"
		statusmenu += "&nbsp;&nbsp;2. 建议：后台模式，用管理器进行HUB日志管理，关闭非必要安全日志/数据包日志提高性能。"
		_caption = "前台模式切换";
	}
	if (itemNum == 3) {
		statusmenu = "&nbsp;&nbsp;用<strong>空格隔开</strong>，常用：443 992 1194 5555"
		_caption = "打开输入的TCP端口通过防火墙入站";
	}
	if (itemNum == 4) {
		statusmenu = "&nbsp;&nbsp;用<strong>空格隔开</strong>，通常L2TP/IPsec服务：500 4500 1701 ；OpenVPN服务：1194";
		_caption = "打开输入的UDP端口通过防火墙入站";
	}
	if (itemNum == 5) {
		statusmenu = "&nbsp;&nbsp;修改服务器的语言（lang.config文件）、自动保存时间和web服务功能（vpn_server.config文件），在服务停止后由脚本操作，修改一次即固化。<br/>"
		_caption = "服务器配置文件修改";
	}
	if (itemNum == 6) {
		statusmenu = "&nbsp;&nbsp;禁用可增强安全性（对应 vpn_server.config 文件的 DisableJsonRpcWebApi 字段）"
		_caption = "禁用内置web服务";
	}
	if (itemNum == 7) {
		statusmenu = "&nbsp;&nbsp;1. 留空即不修改，对应 vpn_server.config 文件的 AutoSaveConfigSpan字段，单位：秒。<br/>"
		statusmenu += "&nbsp;&nbsp;2. 因 VPN 会定时记录流量、用户登录等统计数据，可能的默认值（SE：300，DE：86400），当配置做完并备份以后，若对统计数据不感冒，可以改大一些，以免频繁执行写入，可能的最大值（SE：3600，DE：604800）。<br/>"
		statusmenu += "&nbsp;&nbsp;3. 丢失统计数据不影响使用。"
		_caption = "自动保存配置文件的间隔时间";
	}
	if (itemNum == 8) {
		statusmenu = "&nbsp;&nbsp;1. 使配置文件在RAM中，正常停止服务时才保存。<i>修改配置后应马上重启一次服务</i>。<br/>"
		statusmenu += "&nbsp;&nbsp;2. 某些版本AutoSaveConfigSpan最大3600秒（默认300），若觉得不够大，或不需要统计数据，可试用此模式。此模式下想要保留部分统计数据，可修改AutoSaveConfigSpan为较小的值，然后设置定时保存。"
		_caption = "配置文件TMP模式";
	}
	if (itemNum == 9) {
		statusmenu = "&nbsp;使用系统定时服务检测vpnserver进程，发现异常进行修复。若运行良好，禁用即可。若有以下异常，建议开启：<br/>"
		statusmenu += "&nbsp;&nbsp;1. 进程丢失。<br/>&nbsp;&nbsp;2. 进程虽在运行，但无法连接VPN服务。可能是因某些原因，进程发生奔溃后自动重启（pid会变），导致虚拟网卡桥接失效而无法访问。"
		_caption = "进程检测间隔时间";
	}

	return overlib(statusmenu, OFFSETX, -140, OFFSETY, 5, LEFT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');

	var tag_name = document.getElementsByTagName('a');
	for (var i = 0; i < tag_name.length; i++)
		tag_name[i].onmouseout = nd;

	if (helpcontent == [] || helpcontent == "" || hint_array_id > helpcontent.length)
		return overlib('<#defaultHint#>', HAUTO, VAUTO);
	else if (hint_array_id == 0 && hint_show_id > 21 && hint_show_id < 24)
		return overlib(helpcontent[hint_array_id][hint_show_id], FIXX, 270, FIXY, 30);
	else {
		if (hint_show_id > helpcontent[hint_array_id].length)
			return overlib('<#defaultHint#>', HAUTO, VAUTO);
		else
			return overlib(helpcontent[hint_array_id][hint_show_id], HAUTO, VAUTO);
	}
}
function mOver(obj, hint){
	$(obj).css({
		"color": "#00ffe4",
		"text-decoration": "underline"
	});
	open_hint(hint);
}
function mOut(obj){
	$(obj).css({
		"color": "#fff",
		"text-decoration": ""
	});
	E("overDiv").style.visibility = "hidden";
}
</script>
</head>
<body onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
	<input type="hidden" name="current_page" value="Module_softether.asp"/>
	<input type="hidden" name="next_page" value="Module_softether.asp"/>
	<input type="hidden" name="group_id" value=""/>
	<input type="hidden" name="modified" value="0"/>
	<input type="hidden" name="action_mode" value=""/>
	<input type="hidden" name="action_script" value=""/>
	<input type="hidden" name="action_wait" value="5"/>
	<input type="hidden" name="first_time" value=""/>
	<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>"/>
	<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>"/>
	<table class="content" align="center" cellpadding="0" cellspacing="0">
		<tr>
			<td width="17">&nbsp;</td>
			<td valign="top" width="202">
				<div id="mainMenu"></div>
				<div id="subMenu"></div>
			</td>
			<td valign="top">
				<div id="tabMenu" class="submenuBlock"></div>
				<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
					<tr>
						<td align="left" valign="top">
							<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
								<tr>
									<td bgcolor="#4D595D" colspan="3" valign="top">
										<div>&nbsp;</div>
										<div class="formfonttitle">Softether VPN server</div>
										<div style="float:right; width:15px; height:25px;margin-top:-20px">
											<img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
										</div>
										<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
										<div class="SimpleNote">
											<li>
											开启<a href="https://www.softether.org/" target="_blank"> <i><u>SoftEther VPN</u></i></a>后，需要用
											<a href="http://www.softether-download.com/cn.aspx" target="_blank"><i><u> 管理器 </u></i></a>进行设置。DE指开发版，SE指稳定版。
											<a href="https://www.right.com.cn/forum/thread-8240065-1-1.html" target="_blank"> <i><u>设置教程</u></i></a>&nbsp;&nbsp;
											<a href="https://www.softether.org/4-docs/1-manual/A._Examples_of_Building_VPN_Networks" target="_blank"> <i><u>官方示例</u></i></a>&nbsp;&nbsp;
											<a href="https://github.com/SoftEtherVPN/SoftEtherVPN/releases" target="_blank"> <i><u>管理器DE版</u></i></a>
											<br/><em>重要：用管理器修改配置后，请及时导出备份；或通过本页重启1次服务使配置固化。否则可能因自动保存的时机未到而丢配置！</em>
											</li>
										</div>
										<div class="formfontdesc"></div>
										<table style="margin:10px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
											<thead>
											<tr>
												<td colspan="2">softether开关</td>
											</tr>
											</thead>
											<tr>
											<th>开启softether</th>
												<td colspan="2">
													<div class="switch_field" style="display:table-cell;float: left;">
														<label for="softether_enable">
															<input id="softether_enable" class="switch" type="checkbox" style="display: none;">
															<div class="switch_container" >
																<div class="switch_bar"></div>
																<div class="switch_circle transition_style">
																	<div></div>
																</div>
															</div>
														</label>
													</div>
													<div style="float: left;margin-top:5px;margin-left:30px;">
													<button class="button_gen" href="javascript:void(0)" onclick="open_file('log');">服务器日志</button>
													</div>
												</td>
											</tr>
											<tr>
											<th><a onmouseover="mOver(this, 1)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">运行状态</a></th>
												<td>
													<div id="softether_status"><i><span id="status">获取中...</span></i></div>
												</td>
											</tr>
											<tr>
											<th><a onmouseover="mOver(this, 2)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">前台模式</a></th>
												<td colspan="2">
													<div class="switch_field" style="display:table-cell;float: left;">
														<label for="softether_foreground">
															<input id="softether_foreground" class="switch" type="checkbox" style="display: none;">
															<div class="switch_container" >
																<div class="switch_bar"></div>
																<div class="switch_circle transition_style">
																	<div></div>
																</div>
															</div>
														</label>
													</div>
												</td>
											</tr>
											<tr>
												<th><a onmouseover="mOver(this, 3)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">打开TCP端口入站</a><br/>
												<label><input type="checkbox" id="softether_tcp_v6" name="softether_tcp_v6"><i>包含ipv6</i></label></th>
												<td>
													<input type="text" oninput="this.value=this.value.replace(/[^\d ]/g, '')" class="input_ss_table" id="softether_tcp_ports" name="softether_tcp_ports" maxlength="100" value="" placeholder="空格隔开" />
												</td>
											</tr>
											<tr>
												<th><a onmouseover="mOver(this, 4)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">打开UDP端口入站</a><br/>
												<label><input type="checkbox" id="softether_udp_v6" name="softether_udp_v6"><i>包含ipv6</i></label></th>
												<td>
													<input type="text" oninput="this.value=this.value.replace(/[^\d ]/g, '')" class="input_ss_table" id="softether_udp_ports" name="softether_udp_ports" maxlength="100" value="" placeholder="空格隔开" />
												</td>
											</tr>
											<tr id="watch_time_tr">
											<th><a onmouseover="mOver(this, 9)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">进程检测间隔时间</a></th>
												<td>
													<select id="softether_watch_time" name="softether_watch_time" style="width:60px;vertical-align: middle;" class="input_option">
															<option value="">禁用</option>
															<option value="1">1</option>
															<option value="2">2</option>
															<option value="3">3</option>
															<option value="4">4</option>
															<option value="5">5</option>
															<option value="6">6</option>
															<option value="10">10</option>
															<option value="12">12</option>
															<option value="15">15</option>
															<option value="20">20</option>
															<option value="30">30</option>
															<option value="60">60</option>
														</select>&nbsp;<span>分钟</span>
												</td>
											</tr>
											<thead>
											<tr>
												<td colspan="2">附加功能</td>
											</tr>
											</thead>
											<tr>
											<th><a onmouseover="mOver(this, 5)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">配置文件修改</a><br/>
											<label><input type="checkbox" id="softether_conf_fix" name="softether_conf_fix" onchange="show_hide_element();"><i>开启修改</i></label></th>
												<td colspan="2">
													<p id="mod_conf_bt">
													点击按钮：<input id="cmdBtn4" onclick="mod_conf();" type="button" value="手动修改配置"/><span id="mod_info" style="display:none;">提示</span>
													</p></div>
												</td>
											</tr>
											<tr id="lang_tr">
											<th>语言</th>
												<td>
													<select id="softether_lang" name="softether_lang" style="width:100px;vertical-align: middle;" class="input_option">
															<option value="">-忽略-</option>
															<option value="cn">简体中文</option>
															<option value="en">English</option>
															<option value="ja">日本語</option>
															<option value="tw">繁體中文</option>
														</select>
												</td>
											</tr>
											<tr id="DisableJsonRpcWebApi_tr">
												<th><a onmouseover="mOver(this, 6)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">禁用内置web服务</a></th>
												<td>
													<select id="softether_DisableJsonRpcWebApi" name="softether_DisableJsonRpcWebApi" style="width:75px;vertical-align: middle;" class="input_option">
															<option value="">-忽略-</option>
															<option value="true">是</option>
															<option value="false">否</option>
														</select>
												</td>
											</tr>
											<tr id="AutoSaveConfigSpan_tr">
												<th><a onmouseover="mOver(this, 7)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">自动保存时间(秒)</a></th>
												<td>
													<input type="text" class="input_ss_table" id="softether_AutoSaveConfigSpan" name="softether_AutoSaveConfigSpan" maxlength="50" value="" placeholder="" />
												</td>
											</tr>
											<!--TMP模式 开始-->
											<tr>
												<th><a onmouseover="mOver(this, 8)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">配置文件TMP模式</a><br/>
												<label><input type="checkbox" id="softether_conf_TMP" name="softether_conf_TMP" onchange="show_hide_element();"><i>开启此模式</i></label></th>
												<td><p id="softether_conf_TMP_txt">点击按钮：<input id="cmdBtn3" onclick="backupConf();" type="button" value="手动保存配置"/><span id="backup_info" style="display:none;">提示</span>
												<br/><em>定时保存：每
													<select id="softether_conf_cron_time" name="softether_conf_cron_time" style="width:60px;vertical-align: middle;" class="input_option">
														<option value="2">2</option>
														<option value="3">3</option>
														<option value="4">4</option>
														<option value="5">5</option>
														<option value="6">6</option>
														<option value="7">7</option>
													</select>
													<select id="softether_conf_cron_time2" name="softether_conf_cron_time2" style="width:60px;vertical-align: middle;" class="input_option">
														<option value="2">2</option>
														<option value="3">3</option>
														<option value="4">4</option>
														<option value="6">6</option>
														<option value="8">8</option>
														<option value="12" selected="selected">12</option>
														<option value="24">24</option>
													</select>
													<select id="softether_conf_cron_type" name="softether_conf_cron_type" style="width:60px;vertical-align: middle;" class="input_option" onchange="show_hide_element();">
														<option value="">-空-</option>
														<option value="day">天</option>
														<option value="hour">小时</option>
													</select>
													保存一次配置文件</em>
													</p>
												</td>
											</tr>
											<!--TMP模式 结束-->
										</table>
										<div class="apply_gen">
											<span><input class="button_gen" id="cmdBtn" onclick="onSubmitCtrl();" type="button" value="提交"/></span>
										</div>
										<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
										<div class="KoolshareBottom">
											<br/>论坛技术支持： <a href="https://www.right.com.cn" target="_blank"> <i><u>right.com.cn</u></i></a><br/>
											Shell, Web by： <i>swrt</i><br/>
										</div>
									</td>
								</tr>
							</table>
							<div id="log"  class="contentM_qis" style="box-shadow: 3px 3px 10px #000;margin-top: 70px;">
								<div class="user_title">服务器日志</div>
								<div style="margin-left:15px"><i>当天的日志，文本不会自动刷新，读取自软链接 /tmp/upload/softether_server_log.lnk 。需要获取其他日期的日志需用管理器下载，或到 /tmp/softethervpn/server_log/ 目录查看</i></div>
								<div id="log_view" style="margin: 10px 10px 10px 10px;width:98%;text-align:center;">
									<textarea cols="50" rows="20" wrap="off" id="logtxt" style="width:97%;padding-left:10px;padding-right:10px;border:1px solid #222;font-family:'Courier New', Courier, mono; font-size:11px;background:#475A5F;color:#FFFFFF;outline: none;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
								</div>
								<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
									<input id="close_file" class="button_gen" type="button" onclick="close_file('log');" value="返回主界面">
								</div>
							</div>
						</td>
						<td width="10" align="center" valign="top"></td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	<div id="footer"></div>
</body>
</html>
