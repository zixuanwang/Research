function openprompt(){
	var temp = {
	state0: {
		html:'<p>What area do you want to search(e.g. 94301 or Palo Alto CA)?</p><div class="field"><textarea id="area" name="area"></textarea></div>',
		buttons: { Cancel: false, Next: true },
		focus: 1,
		submit:function(e,v,m,f){ 
			if(!v)
			  	$.prompt.close()
			  else $.prompt.goToState('state1');//go forward
				return false; 
			}
		},
		state1: {
			html:'<p>What is the bugget range?</p><div class="field"><input type="checkbox" name="bugget" id="bugget_cheap" value="Cheap" class="radioinput" /><label for="bugget_cheap">Cheap</label></div><div class="field"><input type="checkbox" name="bugget" id="bugget_middle" value="Middle Class" class="radioinput" /><label for="bugget_cheap">Middle Class</label></div><div class="field"><input type="checkbox" name="bugget" id="bugget_expensive" value="Expensive" class="radioinput" /><label for="expensive">Expensive</label></div>',
			buttons: { Back: -1, Cancel: 0, Next: 1 },
			focus: 2,
			submit:function(e,v,m,f){
				if(v==0)
					$.prompt.close()
				else if(v==1)
					$.prompt.goToState('state2');//go forward
				     else if(v=-1)
					$.prompt.goToState('state0');//go back
				return false; 
				}
			},
		state2: {
			html:'What cuisine do you prefer?<div class="field"><select name="cuisine" id="cuisine"><option value="Search">Search</option><option value="chinese">Chinese</option><option value="French">French</option><option value="Indian">Indian</option><option value="Greek">Greek</option><option value="Any">Any</option></select></div>',
			buttons: { Back: -1, Cancel: 0, Next: 1 },
			focus: 2,
			submit: function(e, v, m, f){
				if (v == 0) 
					$.prompt.close()
				else 
					if (v == 1) 
						$.prompt.goToState('state3');//go forward
					else 
						if (v = -1) 
							$.prompt.goToState('state1');//go back
							return false;
						}
					},
		state3: {
			html:'<p>Please leave any other comments:</p><div class="field"><textarea id="more_comments" name="more_comments"></textarea></div>',
			buttons: { Back: -1, Cancel: 0, Finish: 1 },
			focus: 2,
			submit:function(e,v,m,f){ 
				if(v==0) 
					$.prompt.close()
				else if(v==1)					
					return true; //we're done
				else if(v=-1)
					$.prompt.goToState('state2');//go back
				return false; 
			}
		}
	}
				
	$.prompt(temp,{
		callback: function(e,v,m,f){
		var str = "You have below requirements for the choices <br />";
		$.each(f,function(i,obj){
			str += i + " - <em>" + obj + "</em><br />";
		});	
		//$('#detail_results').html(str);
		$('#detail_results').append(str);
		}
	});
}
	 
