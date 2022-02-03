# Weather Insurance

### The contract

This contract allows anyone to sell a trustless draught insurance policy to anyone else on earth, based on [NASA's ongoing precipitation data feed](https://cmr.earthdata.nasa.gov/search/concepts/C1383813816-GES_DISC.html) measured by the [GPM satellite constellation](https://gpm.nasa.gov/missions/GPM/constellation) via  their [microwave radiometers](https://gpm.nasa.gov/missions/GPM/GMI). Individuals can request an insurance by specifying the conditions under which they want to receive some payout, say "if it rains less than 10L during April 2022 at coordinates XY, pay out 2 ETH", while depositing some insurace fee they would be willing to pay, say 0.5 ETH, into the contract. Any insurer can accept these conditions by depositing the 2 ETH payout amount into the contract, and immediately claim the 0.5 ETH fee. If the insured individual can generate an oracle proof that the draught eventually happened, i.e. it rained less than 10L at XY in April 2022, they can claim their 2 ETH payout. If instead the insurer can prove that it didn't happen, they can reclaim their 2 ETH deposit back.

Here are some ideas for how you could improve the contract logic to create a more compelling product: 
- Add support insuring other types of risks, e.g. fire via [this real-time NASA data feed](https://worldview.earthdata.nasa.gov/?v=-227.166567355547,-113.56806782384763,177.91460589598017,121.72908281176169&l=VIIRS_SNPP_Thermal_Anomalies_375m_Day,VIIRS_SNPP_Thermal_Anomalies_375m_Night,MODIS_Combined_Thermal_Anomalies_All,Reference_Labels_15m(hidden),Reference_Features_15m(hidden),Coastlines_15m,VIIRS_SNPP_CorrectedReflectance_TrueColor(hidden),MODIS_Aqua_CorrectedReflectance_TrueColor(hidden),MODIS_Terra_CorrectedReflectance_TrueColor&lg=false&sh=VIIRS_SNPP_Thermal_Anomalies_375m_Day,C1392010612-LPDAAC_ECS&t=2021-12-29-T16%3A11%3A11Z)
- Invent a mechanism that allows the contract to estimate payout probabilities for all policies (e.g. to automatically price insurance policies), e.g. by incentivizing [prediction markets](https://en.wikipedia.org/wiki/Prediction_market) via dedicated token rewards, or create a incentivized machine learning compentition like [Numerai](https://numer.ai/tournament), with an on-chain leaderboard that rewards the publisher of the best weather-forcasting model, as validated via oracle enclaves
- Once the contract itself can estimate payout probabilities, it could fund all payouts from a single pool of capital which only needs to be roughly as large as the _expected_, rather than the _maximum possible_ total payout. This would dramatically increase capital efficiency and reduce insurance fees.


### The big picture
Every agriculture business needs to insure against weather risk. Most people in low income countries work in the agriculture sector. But in most low income countries, affordable weather insurance is almost nonexistent. One reason is that the size of an individual insurance policy, and thus the fees you could charge per person, are rather small. Therefore, to become affordable, an insurance solution must be operate at a huge scale. Another reason is that people need to be able to trust that they will actually receive the payout if a damage occurs, even if they're unable to take the insurance provider to court. So it's not surprising that the idea of using smart contracts to provide parametric weather insurance to the world has been around for many years, and was already [pursued before](https://www.chainlinkecosystem.com/ecosystem/arbol/).

But as far as we know, that vision hasn't really taken off yet. We don't have a simple answer for why that is, other than that it's just damn hard to profitably provide a compelling weather insurance product in low income countries. And while the problem doesn't immediately get easier if you bring smart contracts into the mix, it's also clear that if there's _any_ way to solve it, it _must_ be online, highly automated, globally trustworthy, and scale efficiently across countries regardless of their local payment infrastructure or institutional context - so there's a good chance it will end up being a smart contract. 



