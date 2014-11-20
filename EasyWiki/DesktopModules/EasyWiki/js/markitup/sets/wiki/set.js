// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------
// Mediawiki Wiki tags example
// -------------------------------------------------------------------
// Feel free to add more tags
// -------------------------------------------------------------------
mySettings = {
	nameSpace:          "easywiki", // Useful to prevent multi-instances CSS conflict
	libraryPath:	'easywiki', //path to pictures library for iframe; set before starting markitup
	previewParserPath:	'', // path to your Wiki parser
	onShiftEnter:		{keepDefault:false, replaceWith:'\n\n'},
	markupSet: [
		{name:'Save',  key:'S', className:'save', beforeInsert:function(markItUp) { easywiki.save(markItUp) } },
		{name:'View',  key:'E', className:'preview', beforeInsert:function(markItUp) { easywiki.view(markItUp) } },
		{separator:'---------------' },
		/* closeWith:' ===', */
		{name:'Heading 1', className: 'H1', key:'1', openWith:'=', closeWith:'=', placeHolder:'Your title here...' },
		{name:'Heading 2', className: 'H2', key:'2', openWith:'==',closeWith:'==',  placeHolder:'Your title here...' },
		{name:'Heading 3', className: 'H3', key:'3', openWith:'===', closeWith:'===', placeHolder:'Your title here...' },
		{name:'Heading 4', className: 'H4', key:'4', openWith:'====', closeWith:'====', placeHolder:'Your title here...' },
		{name:'Heading 5', className: 'H5', key:'5', openWith:'=====', closeWith:'=====', placeHolder:'Your title here...' },
		{separator:'---------------' },		
		{name:'Bold', className:'Bold', key:'B', openWith:"**", closeWith:"**"}, 
		{name:'Italic',  className:'Italic', key:'I', openWith:"//", closeWith:"//"}, 
		{name:'Stroke through', key:'D', className:'Stroke', openWith:'--', closeWith:'--'}, 
		{separator:'---------------' },
		{name:'Bulleted list', className:'Bullet', openWith:'(!(* |!|*)!)'}, 
		{name:'Numeric list', className:'Numeric', openWith:'(!(# |!|#)!)'}, 
		{separator:'---------------' },
		{name:'Picture', key:"P", className:'Picture', replaceWith:'{{[![Url:!:http://]!]|[![name]!]}}'}, 
		{name:'DNN Library',  //pictures
		 className:'preview',  //pictures
		 beforeInsert:function() { 
				$('<iframe src="' + mySettings.libraryPath + '"></iframe>').modal(); [1]
			} 
		}, 
		{separator:'---------------' },
		{name:'Link', key:"L", className:'Link', openWith:"[[[![Link]!]", closeWith:']]' },
		/* {name:'Url', className:'Url', openWith:"[[[![Url:!:http://]!] ", closeWith:']]', placeHolder:'|Your text to link here...' }, */
		{name: 'Url', key: "U", className: 'Url', replaceWith: '[[[![Url:!:http://]!]|[![Title]!]]]' },
        /* key:'W',  */
        {name:'Wikize', className:'wikize', openWith:"[[", closeWith:"]]"},
        {separator:'---------------' },
        /* {name:'Quotes', className: 'Quotes', openWith:'(!(> |!|>)!)', placeHolder:''}, */
		{name:'Code', className:'Code', openWith:'(!({{{\n<pre class="brush:[![Language:!:html]!]">|!|{{{\n<pre>)!)', closeWith:'</pre>\n}}}\n\n<<<code lang=\'[![Language:!:html]!]\'>>>\n'}, 
		{name:'Date', 
         className:"date", 
         replaceWith:function() { 
            var date = new Date()
            var weekday = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
            var monthname = ["January","February","March","April","May","June","July","August","September","October","November","December"];
            var D = weekday[date.getDay()];
            var d = date.getDate();
            var m = monthname[date.getMonth()];
            var y = date.getFullYear();
            var h = date.getHours();
            var i = date.getMinutes();
            var s = date.getSeconds();
            return (D +" "+ d + " " + m + " " + y + " " + h + ":" + i + ":" + s);
         }
        },
		{separator:'---------------' },
		{name:'Preview', call:'preview', className:'preview'}
	]
}
