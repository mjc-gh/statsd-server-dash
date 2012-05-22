$(function(){
	var graph_opts = {
		xaxis: {
			mode: 'time', timeformat: '%h:%M:%S',
			minTickSize: [10, 'second'],
		},

		grid: { borderColor:'#FFF', color:'#FFF' },
		colors: ['#0F0', '#F00', '#00F']
	};

	$('.graph').each(function(){
		var graph = $(this);
		var data = graph.data();

		var path = [data.type, data.level, data.metric].join('/');
		var opts = { type: 'GET', dataType: 'json' };

		$.ajax(path, opts).done(function(data){
			if (data.invalid){
				graph.text("Invalid: "+ results.invalid);

			} else {
				$.plot(graph, [data.results], graph_opts);

			}
		});
	});
});
