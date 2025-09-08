<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Expires" content="-1" />
<link rel="shortcut icon" href="/res/icon-openlist.png" />
<link rel="icon" href="/res/icon-openlist.png" />
<title>软件中心 - OpenList文件列表</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="usp_style.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/device-map/device-map.css">
<link rel="stylesheet" type="text/css" href="/js/table/table.css">
<link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
<link rel="stylesheet" type="text/css" href="/res/softcenter.css">
<script language="JavaScript" type="text/javascript" src="/js/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/js/httpApi.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" language="JavaScript" src="/js/table/table.js"></script>
<script type="text/javascript" language="JavaScript" src="/client_function.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<style>
a:focus {
	outline: none;
}
.SimpleNote {
	padding:5px 5px;
}
i {
	color: #FC0;
	font-style: normal;
}
.loadingBarBlock{
	width:740px;
}
.popup_bar_bg_ks{
	position:fixed;
	margin: auto;
	top: 0;
	left: 0;
	width:100%;
	height:100%;
	z-index:99;
	/*background-color: #444F53;*/
	filter:alpha(opacity=90);  /*IE5、IE5.5、IE6、IE7*/
	background-repeat: repeat;
	visibility:hidden;
	overflow:hidden;
	/*background: url(/images/New_ui/login_bg.png);*/
	background:rgba(68, 79, 83, 0.85) none repeat scroll 0 0 !important;
	background-position: 0 0;
	background-size: cover;
	opacity: .94;
}

.FormTitle em {
	color: #00ffe4;
	font-style: normal;
	/*font-weight:bold;*/
}
.FormTable th {
	width: 30%;
}
.formfonttitle {
	font-family: Roboto-Light, "Microsoft JhengHei";
	font-size: 18px;
	margin-left: 5px;
}
.FormTitle, .FormTable, .FormTable th, .FormTable td, .FormTable thead td, .FormTable_table, .FormTable_table th, .FormTable_table td, .FormTable_table thead td {
	font-size: 14px;
	font-family: Roboto-Light, "Microsoft JhengHei";
}
</style>
<script type="text/javascript">
var db_openlist = {};
var refresh_flag;
var count_down;
var _responseLen;
var STATUS_FLAG;
var noChange = 0;
var params_check = ['openlist_log_std_only', 'openlist_enable', 'openlist_https', 'openlist_publicswitch', 'openlist_open_port'];
var params_input = ['openlist_s3_ssl', 'openlist_s3_port', 'openlist_s3_enable', 'openlist_tls_insecure_skip_verify', 'openlist_sftp_port', 'openlist_ftp_port', 'openlist_sftp_enable', 'openlist_ftp_enable', 'openlist_log_name', 'openlist_log_enable', 'openlist_bin_file', 'openlist_watchdog_time', 'openlist_data_dir', 'openlist_tmp_dir', 'openlist_cert_file', 'openlist_key_file', 'openlist_port', 'openlist_cdn', 'openlist_token_expires_in', 'openlist_site_url', 'openlist_max_connections', 'openlist_delayed_start'];

String.prototype.myReplace = function(f, e){
	var reg = new RegExp(f, "g");
	return this.replace(reg, e);
}

function init() {
	show_menu(menu_hook);
	register_event();
	get_dbus_data();
	check_status();
}

function get_dbus_data(){
	$.ajax({
		type: "GET",
		url: "/_api/openlist_",
		dataType: "json",
		async: false,
		success: function(data) {
			db_openlist = data.result[0];
			conf2obj();
			show_hide_element();
			show_hide_element_2();
			pannel_access();
		}
	});
}

function pannel_access(){
	if(db_openlist["openlist_enable"] == "1"){
		if(E("openlist_https").checked){
			protocol = "https:";
		}else{
			protocol ="http:";
		}

		webUiHref = protocol + "//" + window.location.hostname + ":" + (db_openlist["openlist_port"] || 5244);

		if(! db_openlist["openlist_url_error"] && db_openlist["openlist_publicswitch"] == 1 && db_openlist["openlist_site_url"]){
			webUiHref = db_openlist["openlist_site_url"];
		}

		E("fileb").href = webUiHref;
		E("fileb").innerHTML = "访问 OpenList 面板";
	}
}

function conf2obj(){
	for (var i = 0; i < params_check.length; i++) {
		if(db_openlist[params_check[i]]){
			E(params_check[i]).checked = db_openlist[params_check[i]] != "0";
		}
	}
	for (var i = 0; i < params_input.length; i++) {
		if (db_openlist[params_input[i]]) {
			$("#" + params_input[i]).val(db_openlist[params_input[i]]);
		}
	}
	if (db_openlist["openlist_version"]){
		E("openlist_version").innerHTML = " - " + db_openlist["openlist_version"];
	}

	if (db_openlist["openlist_binver"]){
		E("openlist_binver").innerHTML = "程序版本：<em>" + db_openlist["openlist_binver"] + "</em>";
	}else{
		E("openlist_binver").innerHTML = "程序版本：<em>null</em>";
	}

	if (db_openlist["openlist_webver"]){
		E("openlist_webver").innerHTML = "面板版本：<em>" + db_openlist["openlist_webver"] + "</em>";
	}else{
		E("openlist_webver").innerHTML = "面板版本：<em>null</em>";
	}
}

function show_hide_element(){
	if(db_openlist["openlist_enable"] == "1"){
		E("openlist_pannel_tr").style.display = "";
	}else{
		E("openlist_pannel_tr").style.display = "none";
	}

	// SHOW HIDE
	if(E("openlist_publicswitch").checked == false){
		E("al_cert").style.display = "none";
		E("al_key").style.display = "none";
		E("al_url").style.display = "none";
		E("al_cdn").style.display = "none";
		E("al_open_http_port").style.display = "none";
	}else{
		E("al_url").style.display = "";
		E("al_cdn").style.display = "";
		E("al_open_http_port").style.display = "";
	}
	if(E("openlist_https").checked == false){
		E("al_cert").style.display = "none";
		E("al_key").style.display = "none";
	}else{
		E("al_cert").style.display = "";
		E("al_key").style.display = "";
	}
	
	if(E("openlist_log_enable").value == "false"){
		E("runlog_file_tr").style.display = "none";
		E("log_std_only").style.display = "none";
	}else{
		E("runlog_file_tr").style.display = "";
		E("log_std_only").style.display = "";
	}
	
	if(E("openlist_ftp_enable").value == "true"){
		E("ftp_port").style.display = "";
	}else{
		E("ftp_port").style.display = "none";
	}
	if(E("openlist_sftp_enable").value == "true"){
		E("sftp_port").style.display = "";
	}else{
		E("sftp_port").style.display = "none";
	}
	
	if(E("openlist_s3_enable").value == "true"){
		E("s3_conf").style.display = "";
	}else{
		E("s3_conf").style.display = "none";
	}
}
//日志“仅标准输出”选框逻辑不同，单独列出，以免被联动清空输入值
function show_hide_element_2(){
	var logNameInput = document.getElementById('openlist_log_name');
	if(E("openlist_log_std_only").checked == true) {
		logNameInput.disabled = true;
		logNameInput.value = '/dev/null';
	} else {
		logNameInput.placeholder = '/tmp/openlist_run.log';
		logNameInput.disabled = false;
		if(db_openlist["openlist_log_name"] == '/dev/null' || !db_openlist["openlist_log_name"]) {
			logNameInput.value = '';
		}else{
			logNameInput.value = db_openlist["openlist_log_name"];
		}
	}
}

function menu_hook(title, tab) {
	tabtitle[tabtitle.length - 1] = new Array("", "软件中心", "离线安装", "OpenList文件列表");
	tablink[tablink.length - 1] = new Array("", "Main_Soft_center.asp", "Main_Soft_setting.asp", "Module_openlist.asp");
}

function register_event(){
	$(".popup_bar_bg_ks").click(
		function() {
			count_down = -1;
		});
	$(window).resize(function(){
		var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
		var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
		if($('.popup_bar_bg_ks').css("visibility") == "visible"){
			document.scrollingElement.scrollTop = 0;
			var log_h = E("loadingBarBlock").clientHeight;
			var log_w = E("loadingBarBlock").clientWidth;
			var log_h_offset = (page_h - log_h) / 2;
			var log_w_offset = (page_w - log_w) / 2 + 90;
			$('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
		}
	});
}

function check_status(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "openlist_status.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		dataType: "json",
		data: JSON.stringify(postData),
		success: function (response) {
			E("openlist_status").innerHTML = response.result;
			setTimeout("check_status();", 10000);
		},
		error: function(){
			E("openlist_status").innerHTML = "获取运行状态失败";
			setTimeout("check_status();", 5000);
		}
	});
}

function save(){
	for (var i = 0; i < params_check.length; i++) {
			db_openlist[params_check[i]] = E(params_check[i]).checked ? '1' : '0';
	}
	for (var i = 0; i < params_input.length; i++) {
		if (E(params_input[i])) {
			db_openlist[params_input[i]] = trim(E(params_input[i]).value);
		}
	}

	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "openlist_config.sh", "params": ["web_submit"], "fields": db_openlist};
	$.ajax({
		type: "POST",
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				get_log();
			}
		}
	});
}

function reset_pwd(){
	var savedDir = db_openlist["openlist_data_dir"] || "/jffs/softcenter/openlist";
	if (E("openlist_data_dir").value && E("openlist_data_dir").value != savedDir) {
		alert("填写的数据目录需要先保存，并至少曾启动过一次!");
		return false;
	}

	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "openlist_config.sh", "params": ["resetpwd"], "fields": db_openlist};
	$.ajax({
		type: "POST",
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				get_log(1);
			}
		}
	});
}

function get_log(flag){
	E("ok_button").style.visibility = "hidden";
	showALLoadingBar();
	$.ajax({
		url: '/_temp/openlist_log.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			var retArea = E("log_content");
			if (response.search("XU6J03M16") != -1) {
				retArea.value = response.myReplace("XU6J03M16", " ");
				E("ok_button").style.visibility = "visible";
				retArea.scrollTop = retArea.scrollHeight;
				if(flag == 1){
					count_down = -1;
					refresh_flag = 0;
				}else{
					count_down = 5;
					refresh_flag = 1;
				}
				count_down_close();
				return false;
			}else if (response.length == 0){
				E("loading_block_title").innerHTML = "暂无日志信息 ...";
				E("log_content").value = "日志文件为空，请关闭本窗口！";
				E("ok_button").style.visibility = "visible";
				return false;
			}
			setTimeout("get_log(" + flag + ");", 500);
			retArea.value = response.myReplace("XU6J03M16", " ");
			retArea.scrollTop = retArea.scrollHeight;
		},
		error: function(xhr) {
			E("loading_block_title").innerHTML = "暂无日志信息 ...";
			E("log_content").value = "日志文件为空，请关闭本窗口！";
			E("ok_button").style.visibility = "visible";
			return false;
		}
	});
}

function showALLoadingBar(){
	document.scrollingElement.scrollTop = 0;
	E("loading_block_title").innerHTML = "&nbsp;&nbsp;openlist日志信息";
	E("LoadingBar").style.visibility = "visible";
	var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
	var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	var log_h = E("loadingBarBlock").clientHeight;
	var log_w = E("loadingBarBlock").clientWidth;
	var log_h_offset = (page_h - log_h) / 2;
	var log_w_offset = (page_w - log_w) / 2 + 90;
	$('#loadingBarBlock').offset({top: log_h_offset, left: log_w_offset});
}
function hideALLoadingBar(){
	E("LoadingBar").style.visibility = "hidden";
	E("ok_button").style.visibility = "hidden";
	if (refresh_flag == "1"){
		refreshpage();
	}
}
function count_down_close() {
	if (count_down == "0") {
		hideALLoadingBar();
	}
	if (count_down < 0) {
		E("ok_button1").value = "手动关闭"
		return false;
	}
	E("ok_button1").value = "自动关闭（" + count_down + "）"
		--count_down;
	setTimeout("count_down_close();", 1000);
}

function get_run_log(){
	if(STATUS_FLAG == 0) return;
	$.ajax({
		url: '/_temp/openlist_run_log.lnk',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache: false,
		success: function(response) {
			var retArea = E("log_content_openlist");
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 10) {
				return false;
			} else {
				setTimeout("get_run_log();", 1500);
			}
			retArea.value = response;

			if(E("openlist_stop_log").checked == false){
				retArea.scrollTop = retArea.scrollHeight;
			}
			_responseLen = response.length;

			if (response.length == 0){
				E("log_content_openlist").value = "运行日志文件为空或未启用";
			}

		},
		error: function(xhr) {
			E("log_content_openlist").value = "日志文件为空，请关闭本窗口！";
			setTimeout("get_run_log();", 5000);
		}
	});
}
function show_log_pannel(){
	document.scrollingElement.scrollTop = 0;
	E("log_pannel_div").style.visibility = "visible";
	var page_h = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
	var page_w = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
	var log_h = E("log_pannel_table").clientHeight;
	var log_w = E("log_pannel_table").clientWidth;
	var log_h_offset = (page_h - log_h) / 2;
	var log_w_offset = (page_w - log_w) / 2;
	$('#log_pannel_table').offset({top: log_h_offset, left: log_w_offset});
	STATUS_FLAG = 1;
	get_run_log();
}
function hide_log_pannel(){
	E("log_pannel_div").style.visibility = "hidden";
	STATUS_FLAG = 0;
}
function open_openlist_hint(itemNum) {
	statusmenu = "";
	width = "350px";
	if (itemNum == 1) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;1. 此处显示openlist二进制程序在路由器后台是否运行，详细运行日志可以点击顶部的【openlist运行日志】查看。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;3. 当出现<b>获取运行状态失败或一串混乱数字</b>时，可能是路由器后台登陆超时或者httpd进程崩溃导致，如果是后者，请等待路由器httpd进程恢复，或者自行使用ssh命令：service restart_httpd重启httpd。<br/>"
		_caption = "运行状态";
	}
	if (itemNum == 2) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;1. 此处显示openlist二进制程序的版本号及其内置的openlist面板版本号。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;2. openlist二进制程序下载自openlist的github项目release页面，要注意选中合适的架构，比如某armng机型cpu为bcm67xx，下载openlist-linux-musleabihf-armv7l-lite版本。<br/>"
		_caption = "运行状态";
	}
	if (itemNum == 3) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;点击【重置密码】可以重新生成当前面板的账号和密码，请注意：如果你需要配置webdav，同样应该使用此用户名和密码。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;仅针对已经提交并保存，且初始化完成的数据目录中的数据。若变更了数据目录但未提交并运行一次，则无法使用。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;点击【openlist运行日志】可以实时查看openlist程序的运行情况。"
		_caption = "重置密码";
	}
	if (itemNum == 4) {
		width = "780px";
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;在不同的配置和网络环境下，点击【访问OpenList面板】进入的是不同地址。<br/>初次启动时，<b>初始登录密码出现在插件日志中</b>，若忘记，可点击下表【重置密码】按钮重置。";
		statusmenu += "<br/><br/>";
		statusmenu += "1️⃣<font color='#F00'>局域网访问（http）</font><br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;1. 插件设置：关闭公网访问，然后开启openlist<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;2. 此时点击【访问OpenList面板】是访问内网地址：http://192.168.50.1:5244 或 http://router.asus.com:5244";
		statusmenu += "<br/><br/>";
		statusmenu += "2️⃣<font color='#F00'>公网ddns访问（http）</font><br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;0. 路由器已经配置了ddns，如域名 ax86.ddns.com 解析到路由器的公网ip<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;1. 插件设置：开启公网访问、不开启https<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;2. 插件设置：网站URL可不填、或填 http://ax86.ddns.com:5244，再启动openlist<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;3. 若未填网站URL，此时点击【访问OpenList面板】是访问局域网地址：http://192.168.50.1:5244<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;4. 若已填网站URL，此时点击【访问OpenList面板】是通过填写的URL访问";
		statusmenu += "<br/><br/>";
		statusmenu += "3️⃣<font color='#F00'>公网ddns访问（https）</font><br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;0. 路由器已经配置了ddns，如域名 ax86.ddns.com，且配置了https证书<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;1. 插件设置：开启公网访问、开启https<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;2. 插件设置：证书公钥和私钥默认使用系统内置的，也可以上传自己申请的然后填写<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;3. 插件设置：网站URL可不填，或填 https://ax86.ddns.com:5244，再启动openlist<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;4. 若未填网站URL，此时点击【访问OpenList面板】是访问局域网地址：https://192.168.50.1:5244<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;5. 若已填网站URL，此时点击【访问OpenList面板】是通过填写的URL访问";
		statusmenu += "<br/><br/>";
		_caption = "说明：";
		return overlib(statusmenu, OFFSETX, -160, OFFSETY, 10, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
	}
	if (itemNum == 5) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;采用系统内置定时服务对openlist进行进程守护，如果程序在你的路由器上运行良好，完全可以不使用进程守护。"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;由于openlist对路由器资源占用较多，强烈建议为路由器配置1G及以上的虚拟内存，以保证稳定运行！"
		_caption = "进程守护";
	}
	if (itemNum == 6) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;开启公网访问后，openlist将监听在 0.0.0.0 地址，能从WAN侧地址（包括IPv6）访问路由器的openlist面板。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;关闭公网访问后，openlist将监听在局域网地址如：192.168.50.1上，这样面板仅能从局域网内部访问"
		_caption = "开启公网访问";
	}
	if (itemNum == 7) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;留空默认端口为 5244 。请注意：如果你需要配置webdav，同样应该使用该端口！。<br/><br/>"
		_caption = "面板端口";
	}
	if (itemNum == 8) {
		width = "780px";
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;网站URL可以不配置，但是如果你需要跟朋友分享资源的时候，比如你在局域网内通过http://192.168.50.1:5244登陆了openlist，"
		statusmenu += "此时你想跟朋友分享资源的时候，复制某个文件连接，该连接仍然是http://192.168.50.1:5244/xxxx。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;如果你给路由器配置了ddns访问路由器：https://ax86u.ddns.com:8443，那么可以将：https://ax86u.ddns.com:5244填写进去，然后你复制的文件连接就会是：https://ax86u.ddns.com:5244/xxxx<br/><br/>"
		_caption = "网站URL";
		return overlib(statusmenu, OFFSETX, -160, OFFSETY, 10, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
	}
	if (itemNum == 9) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;openlist运行在路由器上，访问openlist面板时，路由器上的openlist会将面板所需要的网页、javaScript文件、图标等静态资源发送给访问的设备，这会消耗不少的路由器cpu资源。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;此时给openlist后台面板配置静态CDN，这些相关的静态资源就会从公网的CDN服务器商获取，而不再请求路由器内的openlist程序。<br/><br/>"
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;可以点击底部链接进入openlist文档网站，获取官方提供的一些CDN地址（地址有效性自行验证）。<br/><br/>"
		_caption = "CDN地址";
	}
	if (itemNum == 10) {
		width = "650px";
		statusmenu = "1️⃣建议当开启公网访问时启用https（除非你有局域网访问https的需求）！<br/><br/>";
		statusmenu += "2️⃣启用https后，下面的<b>证书公钥Cert文件</b>和<b>证书私钥Key文件</b>选项也必须正确填写！<br/><br/>";
		statusmenu += "3️⃣若为路由器配置了DDNS和https证书，openlist可以使用相同的证书。留空默认使用系统内置证书：<br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;证书Cert文件路径(绝对路径)：<font color='#CC0066'>/etc/cert.pem</font><br/>";
		statusmenu += "&nbsp;&nbsp;&nbsp;&nbsp;证书Key文件路径(绝对路径)：<font color='#CC0066'>/etc/key.pem</font><br/><br/>";
		statusmenu += "4️⃣https启用成功后，后台面板就无法使用http地址进行访问了！<br/><br/>";
		statusmenu += "5️⃣若你使用某些内网穿透服务，需酌情配置，如ddnsto，不要开启https选项！<br/><br/>";
		_caption = "启用https：";
		return overlib(statusmenu, OFFSETX, -30, OFFSETY, 10, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
	}

	if (itemNum == 11) {
		width = "690px";
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;留空将默认使用软件中心安装的二进制可执行文件： <font color='#CC0066'>/jffs/softcenter/bin/openlist</font>"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;如果要自行更新主程序版本，要保证路由器存储空间充足，或者有外置U盘等存储可用"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;二进制下载可点击页面顶部链接进入openlist的github项目，再进入<b> release 页面</b>，看准架构，选择<font color='#CC0066'>带 musl 字样</font>的版本，如某armng路由器cpu为bcm67xx，则下载openlist-linux-musleabihf-armv7l-lite压缩包，再解压得到openlist（<font color='#CC0066'>文件名必须为openlist</font>），传到路由器的非易失性存储（闪存的/jffs或挂载的外置存储）"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;将存储的二进制文件绝对路径（不要有空格）填写到此处即可使用，不会删除原文件"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;如果存储空间足够，下载的二进制文件建议直接使用，不建议用upx压缩！"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;注：软件中心安装的二进制为了节省闪存空间，一般会用upx进行压缩，但运行时消耗较多RAM内存<br/><br/>"
		_caption = "自定义主程序二进制文件路径";
		return overlib(statusmenu, OFFSETX, -30, OFFSETY, 10, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');
	}

	if (itemNum == 12) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;留空默认0，同时最多的连接数(并发)，0即不限制"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;对于一般的设备比如n1推荐10或者20"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;使用场景（例如打开图片模式并发不是很好的设备就会崩溃）"
		_caption = "最大并发连接数";
	}

	if (itemNum == 13) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;留空默认：<font color='#CC0066'>/jffs/softcenter/openlist</font> 配置文件和数据库等文件保存在此处"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;目录名不要有空格"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;不会删除之前的配置目录的任何数据"
		_caption = "自定义数据存储目录";
	}
	if (itemNum == 14) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;本插件，留空默认：<font color='#CC0066'>/tmp/openlist</font> ，程序临时目录。"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;注：openlist默认设置为“数据目录/temp”，本插件为了防止闪存写入进行了修改"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;目录名不要有空格"
		_caption = "自定义缓存目录";
	}
	if (itemNum == 15) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;留空默认0秒，有时候网络连接的慢，导致 OpenList 启动过快后需要网络连接的驱动无法连接导致无法正常打开"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;若填写此项，除在配置文件写入数值外，本插件也会在<font color='#CC0066'>启动脚本中酌情写入延迟启动</font>openlist的指令（系统启动的前3分钟内，延迟最多30秒），可能解决一些异常情况，如虚拟内存还未挂载等"
		_caption = "延时启动";
	}
	if (itemNum == 16) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;默认开启日志。本插件运行日志包含<b>常规运行日志</b>和<b>标准输出</b>，点击顶部的【openlist运行日志】查看。日志文件路径留空，将默认以下路径： "
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;默认不勾选<b>“仅标准输出”</b>，常规运行日志默认配置为 <font color='#CC0066'>/tmp/openlist_run.log</font>（若要改，填写的路径不要有空格），此时标准输出也在此文件中"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;如果已勾选<b>“仅标准输出”</b>，常规运行日志强制固定为 <font color='#CC0066'>/dev/null</font>（被丢弃），此时标准输出在 /tmp/openlist_std.log 文件中"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;注：openList 初始设置是：开启日志并且常规运行日志保存在“数据目录/log/log.log”，标准输出打印在终端"
		_caption = "日志配置";
	}
	if (itemNum == 17) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;默认关闭。开启后，端口留空默认5221"
		statusmenu += "<br/><br/>&nbsp;&nbsp;&nbsp;&nbsp;注：若要修改参数，请关闭插件后手动编辑“数据目录/config.json”中ftp节"
		_caption = "启用 FTP";
	}
	if (itemNum == 18) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;默认关闭。开启后，端口留空默认5222"
		_caption = "启用 SFTP";
	}
	if (itemNum == 19) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;留空默认48小时"
		_caption = "用户登录过期时间";
	}
	if (itemNum == 20) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;是否允许防火墙接受对应端口的入站数据，含面板端口、ftp端口（若启用）、sftp端口（若启用）、s3端口（若启用）"
		_caption = "开放公网端口";
	}
	if (itemNum == 21) {
		statusmenu = "&nbsp;&nbsp;&nbsp;&nbsp;默认开启，即不检查 SSL 证书。关闭后，如使用的网站的证书出现问题（如未包含中级证书、证书过期、证书伪造等），将不能使用服务。"
		_caption = "禁用 TLS 验证";
	}
	if (itemNum == 22) {
		statusmenu = "&nbsp;&nbsp;&nbsp;默认关闭。开启后，端口留空默认5246；SSL默认禁用"
		_caption = "对象存储S3功能";
	}


	return overlib(statusmenu, OFFSETX, 10, OFFSETY, 10, RIGHT, STICKY, WIDTH, 'width', CAPTION, _caption, CLOSETITLE, '');

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
	open_openlist_hint(hint);
}
function mOut(obj){
	$(obj).css({
		"color": "#fff",
		"text-decoration": ""
	});
// 	E("overDiv").style.visibility = "hidden";
}
</script>
</head>
<body id="app" skin='<% nvram_get("sc_skin"); %>' onload="init();">
	<div id="TopBanner"></div>
	<div id="Loading" class="popup_bg"></div>
	<div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;" >
		<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
			<tr>
				<td height="100">
					<div id="loading_block_title" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
					<div id="loading_block_spilt" style="margin:10px 0 10px 5px;" class="loading_block_spilt">
						<li><font color="#ffcc00">请等待日志显示完毕，并出现自动关闭按钮！</font></li>
						<li><font color="#ffcc00">在此期间请不要刷新本页面，不然可能导致问题！</font></li>
					</div>
					<div style="margin-left:15px;margin-right:15px;margin-top:10px;outline: 1px solid #3c3c3c;overflow:hidden">
						<textarea cols="50" rows="25" wrap="off" readonly="readonly" id="log_content" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:5px;padding-right:22px;overflow-x:hidden;white-space:break-spaces;"></textarea>
					</div>
					<div id="ok_button" class="apply_gen" style="background:#000;visibility:hidden;">
						<input id="ok_button1" class="button_gen" type="button" onclick="hideALLoadingBar()" value="确定">
					</div>
				</td>
			</tr>
		</table>
	</div>
	<div id="log_pannel_div" class="popup_bar_bg_ks" style="z-index: 200;" >
		<table cellpadding="5" cellspacing="0" id="log_pannel_table" class="loadingBarBlock" style="width:960px" align="center">
			<tr>
				<td height="100">
					<div style="text-align: center;font-size: 18px;color: #99FF00;padding: 10px;font-weight: bold;">openlist日志信息</div>
					<div style="margin-left:15px"><i>🗒️此处展示openlist程序的运行日志... 【可能某些系统内，日志时间显示比上海时间慢8小时】</i></div>
					<div style="margin-left:15px;margin-right:15px;margin-top:10px;outline: 1px solid #3c3c3c;overflow:hidden">
						<textarea cols="50" rows="32" wrap="off" readonly="readonly" id="log_content_openlist" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:5px;padding-right:22px;line-height:1.3;overflow-x:hidden;white-space:break-spaces;"></textarea>
					</div>
					<div id="ok_button_openlist" class="apply_gen" style="background:#000;">
						<input class="button_gen" type="button" onclick="hide_log_pannel()" value="返回主界面">
						<input style="margin-left:10px" type="checkbox" id="openlist_stop_log">
						<lable>停止自动滚动</lable>
					</div>
				</td>
			</tr>
		</table>
	</div>
	<iframe name="hidden_frame" id="hidden_frame" width="0" height="0" frameborder="0"></iframe>
	<!--=============================================================================================================-->
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
										<div class="formfonttitle">OpenList <lable id="openlist_version"></lable></div>
										<div style="float: right; width: 15px; height: 25px; margin-top: -20px">
											<img id="return_btn" alt="" onclick="reload_Soft_Center();" align="right" style="cursor: pointer; position: absolute; margin-left: -30px; margin-top: -25px;" title="返回软件中心" src="/images/backprev.png" onmouseover="this.src='/images/backprevclick.png'" onmouseout="this.src='/images/backprev.png'" />
										</div>
										<div style="margin: 10px 0 10px 5px;" class="splitLine"></div>
										<div class="SimpleNote">
											<a href="https://github.com/OpenListTeam/OpenList" target="_blank"><em><u>OpenList</u></em></a>&nbsp;一个支持多种存储的文件列表程序，使用 Gin 和 Solidjs。
										</div>
										<div id="openlist_status_pannel">
											<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
												<thead>
													<tr>
														<td colspan="2">OpenList - 状态</td>
													</tr>
												</thead>
												<tr id="openlist_enable_tr">
													<th>总开关</th>
													<td colspan="2">
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="openlist_enable">
																<input id="openlist_enable" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container" >
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
														&nbsp;&nbsp;&nbsp;<a type="button" class="ks_btn" href="javascript:void(0);" onclick="get_log(1)" style="margin-left:5px;">插件日志</a>
														&nbsp;&nbsp;&nbsp;<a type="button" class="ks_btn" href="javascript:void(0);" onclick="show_log_pannel()" style="margin-left:5px;">openlist运行日志</a>
													</td>
												</tr>
												<tr id="openlist_status_tr">
													<th><a onmouseover="mOver(this, 1)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">运行状态</a></th>
													<td>
														<span style="margin-left:4px" id="openlist_status"></span>
													</td>
												</tr>
												<tr id="openlist_version_tr">
													<th><a onmouseover="mOver(this, 2)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">版本信息</a></th>
													<td>
														<span style="margin-left:4px" id="openlist_binver"></span>
														<span style="margin-left:4px" id="openlist_webver"></span>
													</td>
												</tr>
												<tr id="dashboard">
													<th><a onmouseover="mOver(this, 5)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">进程守护间隔</a></th>
													<td>
													<select id="openlist_watchdog_time"  style="width:60px;margin:0px 0px 0px 2px;" class="input_option" >
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
												<tr id="openlist_pannel_tr" style="display: none;">
													<th><a onmouseover="mOver(this, 4)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">OpenList面板</a></th>
													<td>
														<a type="button" style="vertical-align:middle;cursor:pointer;" id="fileb" class="ks_btn" href="" target="_blank">访问 OpenList 面板</a>
													</td>
												</tr>
											</table>
										</div>
										<div id="openlist_setting_pannel" style="margin-top:10px">
											<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
												<thead>
													<tr>
														<td colspan="2">OpenList - 设置</td>
													</tr>
												</thead>
												<tr id="dashboard">
													<th><a onmouseover="mOver(this, 6)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">开启公网访问</a></th>
													<td>
														<input type="checkbox" id="openlist_publicswitch" onchange="show_hide_element();" style="vertical-align:middle;">
													</td>
												</tr>
												<tr id="al_open_http_port">
													<th><a onmouseover="mOver(this, 20)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">开放公网端口</a></th>
													<td>
														<input type="checkbox" id="openlist_open_port" style="vertical-align:middle;">
													</td>
												</tr>
												<tr id="openlist_port_tr">
													<th><a onmouseover="mOver(this, 7)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">面板端口</a></th>
													<td>
														<input type="text" id="openlist_port" oninput="this.value=this.value.replace(/[^\d-]/g, ''); if(value>65535)value=65535" style="width: 50px;" maxlength="5" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="5244">
													</td>
												</tr>
												<tr id="al_url">
													<th><a onmouseover="mOver(this, 8)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">网站URL (site_url)</a><lable id="warn_url" style="color:red;margin-left:5px"><lable></th>
													<td>
													<input type="text" id="openlist_site_url" style="width: 95%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="">
													</td>
												</tr>
												<tr id="al_cdn">
													<th><a onmouseover="mOver(this, 9)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">静态资源CDN地址<lable id="warn_cdn" style="color:red;margin-left:5px"><lable></a></th>
													<td>
													<input type="text" id="openlist_cdn" style="width: 95%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="">
													</td>
												</tr>
												<tr id="al_https">
													<th><a onmouseover="mOver(this, 10)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">启用https</a></th>
													<td>
														<input type="checkbox" id="openlist_https" onchange="show_hide_element();" style="vertical-align:middle;" />
														<span id="warn_cert" style="color:red;margin-left:5px;vertical-align:middle;font-size:11px;"><span>
													</td>
												</tr>
												<tr id="al_cert">
													<th><a onmouseover="mOver(this, 10)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">证书公钥Cert文件</a></th>
													<td>
													<input type="text" id="openlist_cert_file" style="width: 50%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="/etc/cert.pem">
													</td>
												</tr>
												<tr id="al_key">
													<th><a onmouseover="mOver(this, 10)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">证书私钥Key文件</a></th>
													<td>
													<input type="text" id="openlist_key_file" style="width: 50%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="/etc/key.pem">
													</td>
												</tr>
												<tr>
													<th><a onmouseover="mOver(this, 15)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">延迟启动</a></th>
													<td>
														<input onkeyup="this.value=this.value.replace(/[^0-9]{1,3}/,'')" style="width:50px;" type="text" class="input_ss_table" id="openlist_delayed_start" name="openlist_delayed_start" maxlength="4" autocorrect="off" autocapitalize="off" value="" placeholder="0">
														<span>秒</span>
													</td>
												</tr>
												<tr>
													<th><a onmouseover="mOver(this, 19)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">用户登录过期时间</a></th>
													<td>
														<input onkeyup="this.value=this.value.replace(/\D/g,'')" style="width:50px;" type="text" class="input_ss_table" id="openlist_token_expires_in" name="openlist_token_expires_in" maxlength="4" autocorrect="off" autocapitalize="off" value="" placeholder="48">
														<span>小时</span>
													</td>
												</tr>
												<tr>
													<th><a onmouseover="mOver(this, 12)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">最大并发连接数</a></th>
													<td>
														<input onkeyup="this.value=this.value.replace(/\D/g,'')" style="width:50px;" type="text" class="input_ss_table" id="openlist_max_connections" name="openlist_max_connections" maxlength="4" autocorrect="off" autocapitalize="off" value="" placeholder="0">
													</td>
												</tr>
												<tr>
													<th><a onmouseover="mOver(this, 21)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">禁用 TLS 验证</a></th>
													<td>
													<select id="openlist_tls_insecure_skip_verify" style="width: 60px;margin:0px 0px 0px 2px;" class="input_option" >
														<option value="">默认</option>
														<option value="true">开启</option>
														<option value="false">关闭</option>
													</select>
													</td>
												</tr>
												<tr id="runlog_enable">
													<th><a onmouseover="mOver(this, 16)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">运行日志</a></th>
													<td>
													<select id="openlist_log_enable" onchange="show_hide_element();" style="width: 60px;margin:0px 0px 0px 2px;" class="input_option" >
														<option value="">默认</option>
														<option value="true">开启</option>
														<option value="false">禁用</option>
													</select>
													<span id="log_std_only"><input type="checkbox" id="openlist_log_std_only" onchange="show_hide_element_2();" style="vertical-align:middle;;margin-left:50px;">仅标准输出</span>
													</td>
												</tr>
												<tr id="runlog_file_tr">
													<th><a onmouseover="mOver(this, 16)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">日志文件路径</a></th>
													<td>
													<input type="text" id="openlist_log_name" style="width: 50%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="">
													</td>
												</tr>
												<tr id="openlist_tmp_tr">
													<th><a onmouseover="mOver(this, 14)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">缓存目录</a></th>
													<td>
													<input type="text" id="openlist_tmp_dir" style="width: 50%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="/tmp/openlist">
													</td>
												</tr>
												<tr id="ftp_enable">
													<th><a onmouseover="mOver(this, 17)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">FTP</a></th>
													<td>
													<select id="openlist_ftp_enable" onchange="show_hide_element();" style="width: 60px;margin:0px 0px 0px 2px;" class="input_option" >
														<option value="">默认</option>
														<option value="true">开启</option>
														<option value="false">禁用</option>
													</select>
													<span id="ftp_port">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;端口：<input type="text" id="openlist_ftp_port" oninput="this.value=this.value.replace(/[^\d]/g, '').replace(/^0{1,}/g,''); if(value>65535)value=65535" style="width: 50px;" maxlength="5" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="5221"></span>
													</td>
												</tr>
												<tr id="sftp_enable">
													<th><a onmouseover="mOver(this, 18)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">SFTP</a></th>
													<td>
													<select id="openlist_sftp_enable" onchange="show_hide_element();" style="width: 60px;margin:0px 0px 0px 2px;" class="input_option" >
														<option value="">默认</option>
														<option value="true">开启</option>
														<option value="false">禁用</option>
													</select>
													<span id="sftp_port">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;端口：<input type="text" id="openlist_sftp_port" oninput="this.value=this.value.replace(/[^\d]/g, '').replace(/^0{1,}/g,''); if(value>65535)value=65535" style="width: 50px;" maxlength="5" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="5222"></span>
													</td>
												</tr>
												<tr>
													<th><a onmouseover="mOver(this, 22)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">对象存储S3</a></th>
													<td>
													<select id="openlist_s3_enable" onchange="show_hide_element();" style="width: 60px;margin:0px 0px 0px 2px;" class="input_option" >
														<option value="">默认</option>
														<option value="true">开启</option>
														<option value="false">禁用</option>
													</select>
													<span id="s3_conf">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;端口：<input type="text" id="openlist_s3_port" oninput="this.value=this.value.replace(/[^\d]/g, '').replace(/^0{1,}/g,''); if(value>65535)value=65535" style="width: 50px;" maxlength="5" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="5246">
													&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;SSL：
													<select id="openlist_s3_ssl" style="width: 60px;margin:0px 0px 0px 2px;" class="input_option" >
														<option value="">默认</option>
														<option value="true">开启</option>
														<option value="false">禁用</option>
													</select></span>
													</td>
												</tr>
												<tr id="openlist_bin_tr">
													<th><a onmouseover="mOver(this, 11)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">重设主程序路径</a></th>
													<td>
													<input type="text" id="openlist_bin_file" style="width: 50%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="/jffs/softcenter/bin/openlist">
													</td>
												</tr>
												<tr id="openlist_data_tr">
													<th><a onmouseover="mOver(this, 13)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">重设数据目录</a></th>
													<td>
													<input type="text" id="openlist_data_dir" style="width: 50%;" class="input_3_table" autocorrect="off" autocapitalize="off" style="background-color: rgb(89, 110, 116);" value="" placeholder="/jffs/softcenter/openlist">
													</td>
												</tr>
												<tr id="openlist_info_tr">
													<th><a onmouseover="mOver(this, 3)" onmouseout="mOut(this)" class="hintstyle" href="javascript:void(0);">重置密码</a></th>
													<td>
														<a type="button" style="vertical-align:middle;cursor:pointer;" class="ks_btn" href="javascript:void(0);" onclick="reset_pwd()" style="margin-left:5px;">重置密码</a>
													</td>
												</tr>
											</table>
										</div>
										<div id="openlist_apply" class="apply_gen">
											<input class="button_gen" id="openlist_apply_btn_1" href="javascript:void(0);" onclick="save()" type="button" value="提交" />
										</div>
										<div style="margin: 10px 0 10px 5px;" class="splitLine"></div>
										<div style="margin:10px 0 0 5px">
											<li>建议挂载U盘并配合虚拟内存插件一起食用，口感更佳，否则可能会出现莫名的问题。</li>
											<li>如有不懂，特别是配置文件的填写，请查看OpenList官方文档：<a href="https://doc.oplist.org/" target="_blank"><em>点这里看文档</em></a>。</li>
											<li>上表<strong>未列出的</strong>配置，可关闭插件后直接修改配置文件【数据目录/config.json】，这些不会被还原。</li>
										</div>
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</td>
			<td width="10" align="center" valign="top"></td>
		</tr>
	</table>
	<div id="footer"></div>
</body>

