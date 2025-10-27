<script>
	let { colorScale } = $props();
</script>

<div class="legend">
	<div class="legend-title">% selecting behavior as civic responsibility</div>
	<div class="gradient-bar">
		<div
			class="gradient-fill"
			style="background: linear-gradient(to right, {colorScale(0)}, {colorScale(25)}, {colorScale(
				50
			)}, {colorScale(75)}, {colorScale(100)});"
		></div>
	</div>
	<div class="legend-labels">
		<span>0%</span>
		<span>100%</span>
	</div>
</div>

<style lang="scss">
	.legend {
		width: 100%;
		max-width: 250px;
		position: absolute;
		bottom: 2rem;
		right: 2rem;

		@include mq('mobile', 'max') {
			left: 50%;
			transform: translateX(-50%);
			right: auto;
		}

		.legend-title {
			font-size: 12px;
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
