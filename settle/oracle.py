import opencontracts
import os, h5py
from earthdata import Auth, DataGranules, DataCollections, Accessor
from datetime import datetime

with opencontracts.session() as session:
  lat, lon = session.user_input('Which coordinates is the policy for? (Latitude, Longitude)').split(',')
  lat, lon = int(lat), int(lon)
  mo, yr = session.user_input('Which period is the policy for? (MM/YY)').split('/')
  mo, yr = int(mo), int(yr)
  threshold = int(session.user_input('What is the rainfall threshold at which the policy pays out?'))
  policyID = session.keccak(lat, lon, yr, mo, threshold,
                            types=('int8', 'int8', 'uint8', 'uint8', 'uint8'))
  session.print(f'You are about to settle the insurance with policyID {"0x"+policyID.hex()}.')
  
  os.environ["CMR_USERNAME"] = session.user_input('Username for NASA Earthdata API:')
  os.environ["CMR_PASSWORD"] = session.user_input('Password for NASA Earthdata API:')
  session.expect_delay(20, 'Downloading [NASA data](https://cmr.earthdata.nasa.gov/search/concepts/C1383813816-GES_DISC.html)...')
  auth = Auth()
  assert auth.login(strategy='environment'), "Invalid Credentials"
  granules = DataGranules(auth).short_name(
      "GPM_3GPROFGPMGMI"
    ).temporal(
      date_from=datetime(2000+yr, mo, 1).isoformat(),
      date_to=datetime(2000+yr, mo, 1).isoformat()
    )
  Accessor(auth).get(granules.get(), './dl')
  f = h5py.File('./dl/'+os.listdir('./dl')[0],'r')
  
  data = f['Grid']['surfacePrecipitation'][:, :]
  data[data<0] = float('nan')
  precipitation = data[round((lon+180)/360*1440), round((lat+70)/140*720)].item() * 1000
  assert precipitation == precipitation, "Precipitation data is NaN, likely wrong coordinates."
  
  damage_occured = precipitation < threshold
  msg = f'Validated Precipitation of {precipitation} on {mo}/{yr} at ({lat},{lon}), '
  msg += f'which means the damage did{" not"*(not damage_occured)} occur.'
  session.print(msg)
  beneficiary = session.user_input('Address of Beneficiary:')
  session.submit(beneficiary, policyID, damage_occured, types=('address', 'bytes32', 'bool',), function_name='settle')
