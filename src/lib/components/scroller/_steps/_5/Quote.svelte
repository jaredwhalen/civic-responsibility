<script>
	let { children, color = '#00aabb', direction = 'left' } = $props();
</script>

<div class="quote-box" style:--color={color}>
	<div class="quote-content">
		<p>{@render children?.()}</p>
	</div>
</div>

<style lang="scss">
	.quote-box {
		position: relative;
		display: inline-block;
		padding: 20px 30px;
		color: var(--color);
        white-space: nowrap;
        opacity: 0.5;
	}

	/* common */
	.quote-box::before,
	.quote-box::after {
		content: '';
		position: absolute;
		pointer-events: none;
		width: calc(100% - 40px);
		height: calc(100% - 40px);
		border: 2px solid var(--color);
	}

	/* TOP + RIGHT (open on left/top) */
	.quote-box::before {
		top: 0;
		right: 0; /* anchor to top-right */
		border-left: none; /* hide left & bottom */
		border-bottom: none;
		border-radius: 0 20px 0 0;
	}

	/* BOTTOM + LEFT (open on right/bottom) */
	.quote-box::after {
		bottom: 0;
		left: 0; /* anchor to bottom-left */
		border-right: none; /* hide right & top */
		border-top: none;
		border-radius: 0 0 0 20px;
	}

	/* quotes (optional) */
	.quote-box p::before,
	.quote-box p::after {
		position: absolute;
		font-size: 8rem;
		color: var(--color);
	}
	.quote-box p::before {
		content: '“';
		top: -50px;
		left: -20px;
	}
	.quote-box p::after {
		content: '”';
		bottom: -110px;
		right: -20px;
	}
</style>
