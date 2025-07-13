<script>
	export let className = '';
</script>

<section class={`slide ${className}`}>
	<div class="slide-inner">
		<slot />
	</div>
</section>

<style lang="scss">
.slide {
	height: 100vh;
	display: flex;
	align-items: center;
	justify-content: center;
	padding: $spacing-xl 0;

	.slide-inner {
		max-width: 800px;
		background: #fff;
		padding: $spacing-xl;
		border-radius: $border-radius-lg;
		margin: 0 auto;
		width: 100%;
		text-align: center;
	}
}
</style> 