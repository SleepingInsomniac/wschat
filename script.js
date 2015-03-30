function randInt(min, max) {
	return Math.round(Math.random() * (max - min) + min);
}


function Color(r,g,b) {
	this.red   = r || randInt(0,255);
	this.green = g || randInt(0,255);
	this.blue  = b || randInt(0,255);
	
	return this;
}

Color.prototype = {
	red: null,
	green: null,
	blue: null
};

Color.prototype.toString = function() {
	return 'rgb('+this.red+','+this.green+','+this.blue+')';
}

var myName = 'Someone';
var color = new Color();

document.getElementById('msgbox').style.color = color.toString();

function addMessage(msg) {
	var chat = document.getElementById('chat');
	var li = document.createElement('li');
	var sender = document.createElement('aside');
	var messageText = document.createElement('p');
	var colorBlock = document.createElement('span');
	
	sender.textContent = msg.sender + ' @ ' + msg.time;
	messageText.textContent = msg.msg;
	
	colorBlock.className = 'colorBlock';
	
	li.appendChild(colorBlock);
	li.appendChild(sender);
	li.appendChild(messageText);
	
	colorBlock.style.backgroundColor = new Color(msg.color.red, msg.color.green, msg.color.blue).toString();
	// if ((msg.color.red + msg.color.green + msg.color.blue) > 400) {
	// 	colorBlock.style.backgroundColor = new Color(50,50,50).toString();
	// }
	chat.appendChild(li);
	chat.scrollTop = chat.scrollHeight;
}

function sendMessage(msg) {
	document.getElementById('msgbox').value = '';
	msg = JSON.stringify({
		sender: myName,
		color: color,
		msg: msg
	});
	ws.send(msg);
	document.getElementById('msgbox').focus();
}

var ws;

function connect() {
	
	ws = new WebSocket('ws://127.0.0.1:3001');
	
	ws.onopen = function(evt) {
		console.log(evt);
	}
	
	ws.onclose = function(evt) {
		console.log(evt);
		addMessage({
			sender: 'Notice',
			msg: 'You were disconnected! Will try again in 10 seconds.',
			color: {red: 255, green: 10, blue: 10},
			time: '-'
		});
		setTimeout(function() {
			addMessage({
				sender: 'Notice',
				msg: 'Attempting reconnection...',
				color: {red: 255, green: 10, blue: 10},
				time: '-'
			});
			connect();
		}, 10000);
	}
	
	ws.onmessage = function(evt) {
		var data = JSON.parse(evt.data);
		console.log(data);
		if (data.msg) addMessage(data);
	}
	
}

window.onload = function() {
	connect();
	document.getElementById('msgbox').focus();
	document.getElementById('msgbox').onkeypress = function(e) {
		if (e.keyCode == 13) {
			sendMessage(this.value);
			return false;
		}
	};
	
}
