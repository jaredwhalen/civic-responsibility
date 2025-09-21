<script>
	let { colorScale } = $props();

	let range = colorScale.range();
</script>

<div class="legend">
	<div class="legend-title">Mean agreement rate</div>
	<div class="gradient-bar">
		<div
			class="gradient-fill"
			style="background: linear-gradient(to right, {range[0]}, {range[1]});"
		></div>
	</div>
	<div class="legend-labels">
		<span>0%</span>
		<span>100%</span>
	</div>
</div>

<style lang="scss">
	.legend {
	
		margin-bottom: 20px;

		width: 100%;
		max-width: 250px;

		.legend-title {
			font-size: 14px;
			font-weight: 800;
			color: #666;
			font-family: sans-serif;
		}

		.gradient-bar {
			width: 100%;
			height: 15px;

			overflow: hidden;
			margin-bottom: 2px;

			.gradient-fill {
				width: 100%;
				height: 100%;
			}
		}

		.legend-labels {
			display: flex;
			justify-content: space-between;
			font-size: 12px;
			color: #666;
		}
	}
</style>
