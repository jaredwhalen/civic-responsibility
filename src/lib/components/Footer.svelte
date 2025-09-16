<script>
// No props for now
</script>

<footer class="footer-root">
	<div class="footer-content">
		<div class="footer-section">
			<h2 class="footer-title">ABOUT THE BEACON PROJECT</h2>
			<p>
				We are a multi-year effort at More in Common to develop a new civic vision for America that speaks to modern challenges.
			</p>
		</div>
		<div class="footer-section">
			<h2 class="footer-title">ABOUT MORE IN COMMON</h2>
			<p>
				Our mission is to understand the forces driving societies apart, find common ground, and bring people together to tackle shared challenges. We work in partnership with a wide range of civil society groups, as well as philanthropy, business, faith, education, media and government to connect people across the lines of difference.
			</p>
		</div>
	</div>
	<div class="footer-logos">
		<div class="footer-logo footer-logo-mic">More in Common</div>
		<div class="footer-logo footer-logo-beacon">BEACON PROJECT</div>
	</div>
</footer>

<style lang="scss">
.footer-root {
	background: linear-gradient(135deg, var(--color-theme-blue), #111);

	color: #fff;
	padding: 3rem;
	position: relative;
	box-shadow: 0 2px 12px rgba(0,0,0,0.12);
	
	font-family: $font-family-primary;
}
.footer-content {
	display: flex;
	flex-direction: column;
	gap: 2rem;
	max-width: 700px;
	margin: 0 auto 0 0;
}
.footer-section {
	margin-bottom: 0.5rem;
}
.footer-title {
	color: #e3c14c;
	font-size: 1.1rem;
	font-weight: 600;
	margin-bottom: 0.5rem;
	letter-spacing: 0.03em;
	text-transform: uppercase;
}
.footer-logos {
	position: absolute;
	bottom: 1.5rem;
	right: 2rem;
	display: flex;
	gap: 2rem;
	align-items: center;
}
.footer-logo {
	color: #fff;
	font-size: 1rem;
	font-weight: 600;
	opacity: 0.85;
	&.footer-logo-mic {
		font-family: $font-family-primary;
	}
	&.footer-logo-beacon {
		font-family: serif;
		letter-spacing: 0.08em;
	}
}
@media (max-width: 700px) {
	.footer-content {
		max-width: 100%;
	}
	.footer-logos {
		position: static;
		margin-top: 2rem;
		justify-content: flex-start;
	}
}
</style> 