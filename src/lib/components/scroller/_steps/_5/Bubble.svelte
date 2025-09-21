<script>
	let { children, color = '#00aabb', direction = 'left' } = $props();
</script>

<div class="speech-bubble {direction}" style:--color={color}>
	{@render children?.()}
</div>

<style lang="scss">
	.speech-bubble {
		position: relative;
		background: var(--color);
		border-radius: 0.4em;
		color: #000;
		padding: 1rem;
		max-width: 320px;
		width: 100%;
		font-size: 1.5rem;
		opacity: 0.5;

		&.right {
			text-align: right;
		}

		&::after {
			content: '';
			position: absolute;
			bottom: 0;
			left: 30%;
			width: 0;
			height: 0;
			margin-left: -10px;
			margin-bottom: -15px;
			border: 20px solid transparent;
			border-bottom: 0;
			border-top-color: var(--color);
		}

		&.left::after {
			left: 30%;
			border-left: 0;
		}

		&.right::after {
			left: calc(70% + 20px);

			border-right: 0;
		}
	}
</style>
