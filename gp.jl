### A Pluto.jl notebook ###
# v0.14.8

using Markdown
using InteractiveUtils

# ╔═╡ 31bacdf0-d04c-11eb-19b0-4389a4a917df
begin
	import JSON, HTTP
	using DataFrames
	using KernelFunctions
	using Turing
end

# ╔═╡ 6def882b-703e-4c0c-b145-4dad250d217a
md"""
# Loading data from CoVariants.org
"""

# ╔═╡ 0bb501e2-810f-4564-bf56-5b0c1a66932a
begin
	req = HTTP.request("GET", "https://raw.githubusercontent.com/hodcroftlab/covariants/master/cluster_tables/21A.Delta_data.json")
	data = JSON.parse(String(req.body))
end

# ╔═╡ f4d18682-da49-4ecb-830b-4912005222c5
md"""
Meld each data set into a big DataFrame
"""


# ╔═╡ 01532dfb-89a5-4dd1-b551-758f50938242
df = data["USA"] |> DataFrame

# ╔═╡ 1623c631-258e-4707-842a-c3afe9f47f60
begin
	time = collect(Float64,1:1:nrow(df))
	prop = df.cluster_sequences./df.total_sequences
end

# ╔═╡ a7a86b5b-0dd0-4847-a428-6dcccd57ef12
md"""
Let's define a RBF Kernel
"""

# ╔═╡ 844b73bb-1b22-4b0b-be2f-7b29597ae8fe
kernel = SqExponentialKernel()

# ╔═╡ 4bebffbd-0b7f-48d4-aef9-30abd8782953
df.cluster_sequences./df.total_sequences

# ╔═╡ Cell order:
# ╠═31bacdf0-d04c-11eb-19b0-4389a4a917df
# ╟─6def882b-703e-4c0c-b145-4dad250d217a
# ╠═0bb501e2-810f-4564-bf56-5b0c1a66932a
# ╟─f4d18682-da49-4ecb-830b-4912005222c5
# ╠═01532dfb-89a5-4dd1-b551-758f50938242
# ╠═1623c631-258e-4707-842a-c3afe9f47f60
# ╟─a7a86b5b-0dd0-4847-a428-6dcccd57ef12
# ╠═844b73bb-1b22-4b0b-be2f-7b29597ae8fe
# ╠═4bebffbd-0b7f-48d4-aef9-30abd8782953
