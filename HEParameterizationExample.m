%% 802.11ax Parameterization for Waveform Generation and Simulation
%
% This example shows how to parameterize and generate different IEEE(R)
% 802.11ax(TM) high efficiency (HE) format packets.

% Copyright 2017-2019 The MathWorks, Inc.

%% Introduction
% IEEE P802.11ax/D3.1 [ <#39 1> ] specifies four high efficiency (HE)
% packet formats:
%
% # Single user
% # Extended range single user
% # Multi user
% # Trigger-based
%
% This example shows how packets can be generated for these different
% formats, and demonstrates some of the key features of the draft standard
% [ <#39 1> ].


%% HE Multi User Format - OFDMA
% The HE multi-user (HE-MU) format can be configured for an OFDMA
% transmission, a MU-MIMO transmission, or a combination of the two. This
% flexibility allows an HE-MU packet to transmit to a single user over the
% whole band, multiple users over different parts of the band (OFDMA), or
% multiple users over the same part of the band (MU-MIMO).
%
% For an OFDMA transmission, the channel bandwidth is divided into resource
% units (RUs). An RU is a group of subcarriers assigned to one or more
% users. An RU is defined by a size (the number of subcarriers) and an
% index. The RU index specifies the location of the RU within the channel.
% For example, in an 80 MHz transmission there are four possible 242-tone
% RUs, one in each 20 MHz subchannel. RU# 242-1 (size 242, index 1) is the
% RU occupying the lowest absolute frequency within the 80 MHz, and RU#
% 242-4 (size 242, index 4) is the RU occupying the highest absolute
% frequency. The draft standard defines possible sizes and location of RUs
% in Section 28.3.3.2 of [ <#39 1> ].
%
% The assignment of RUs in a transmission is defined by the allocation
% index. The allocation index is defined in Table 28-24 of [ <#39 1> ]. For
% each 20 MHz subchannel, an 8 bit index describes the number and size of
% RUs, and the number of users transmitted on each RU. The allocation index
% also determines which content channel is used to signal a user in
% HE-SIG-B. The allocation indices within Table 28-24, and the
% corresponding RU assignments, are provided in the table returned by the
% function |heRUAllocationTable|. The first 10 allocations within the table
% are shown below. For each allocation index, the 8 bit allocation index,
% the number of users, number of RUs, RU indices, RU sizes, and number of
% users per RU are displayed. A note is also provided about allocations
% which are reserved, or serve a special purpose. The allocation table can
% also be viewed in the <#38 Appendix>.

allocationTable = heRUAllocationTable;
disp('First 10 entries in the allocation table: ')
disp(allocationTable(1:10,:));

%%
% A <matlab:doc('wlanHEMUConfig') wlanHEMUConfig> object is used to
% configure the transmission of an HE-MU packet. The allocation index for
% each 20 MHz subchannel must be provided when creating an HE-MU
% configuration object, <matlab:doc('wlanHEMUConfig') wlanHEMUConfig>. An
% integer between 0 and 223, corresponding to the 8-bit number in Table
% 28-24 of [ <#39 1> ], must be provided for each 20 MHz subchannel.
%
% The allocation index can be provided as a decimal or 8-bit binary
% sequence. In this example, a 20 MHz HE-MU configuration is created with 8
% bit allocation index "10000000". This is equivalent to the decimal
% allocation index 128. This configuration specifies 3 RUs, each with one
% user.

allocationIndex = "10000000"; % 3 RUs, 1 user per RU
cfgMU = wlanHEMUConfig(allocationIndex);

%%
% The |showAllocation| method visualizes the occupied RUs and subcarriers
% for the specified configuration. The colored blocks illustrate the
% occupied subcarriers in the pre-HE and HE portions of the packet. White
% indicates subcarriers are unoccupied. The pre-HE portion illustrates the
% occupied subcarriers in the fields preceding HE-STF. The HE portion
% illustrates the occupied subcarriers in the HE-STF, HE-LTF and HE-Data
% field and therefore shows the RU allocation. Clicking on an RU will
% display information about the RU. The RU number corresponds to the i-th
% RU element of the |cfgMU.RU| property. The size and index are the details
% of the RU. The RU index is the i-th possible RU of the corresponding RU
% size within the channel bandwidth, for example Index 2 is the 2nd
% possible 106-tone RU within the 20 MHz channel bandwidth. The user number
% correspond to the i-th User element of the |cfgMU.User| property, and the
% user field in HE-SIG-B. Note the middle RU (RU #2) is split across the DC
% subcarriers.

showAllocation(cfgMU);
axAlloc = gca; % Get axis handle for subsequent plotting

%%
% The |ruInfo| method provides details of the RUs in the configuration. In
% this case we can see three users and three RUs.

allocInfo = ruInfo(cfgMU);
disp('Allocation info:')
disp(allocInfo)

%%
% The properties of |cfgMU| describe the transmission configuration. The
% |cfgMU.RU| and |cfgMU.User| properties of |cfgMU| are cell arrays. Each
% element of the cell arrays contains an object which configures an RU or
% a User. When the |cfgMU| object is created, the elements of |cfgMU.RU| and
% |cfgMU.User| are configured to create the desired number of RUs and
% users. Each element of |cfgMU.RU| is a <matlab:doc('wlanHEMURU')
% wlanHEMURU> object describing the configuration of an RU. Similarly, each
% element of |cfgMU.User| is a <matlab:doc('wlanHEMUUser') wlanHEMUUser>
% object describing the configuration of a User. This object hierarchy is
% shown below:
%
% <<../heParameterization.png>>
%
% In this example, three RUs are specified by the allocation index 128,
% therefore |cfgMU.RU| is a cell array with three elements. The index and
% size of each RU are configured according to the allocation index used to
% create |cfgMU|. After the object is created, each RU can be configured to
% create the desired transmission configuration, by setting the properties
% of the appropriate RU object. For example, the spatial mapping and power
% boost factor can be configured per RU. The |Size| and |Index| properties
% of each RU are fixed once the object is created, and therefore are
% read-only properties. Similarly, the |UserNumbers| property is read-only
% and indicates which user is transmitted on the RU. For this configuration
% the first RU is size 106, index 1.

disp('First RU configuration:')
disp(cfgMU.RU{1})

%%
% In this example, the allocation index specifies three users in the
% transmission, therefore |cfgMU.User| contains three elements. The
% transmission properties of users can be configured by modifying
% individual user objects, for example the MCS, APEP length and channel
% coding scheme. The read-only |RUNumber| property indicates which RU is
% used to transmit this user.

disp('First user configuration:')
disp(cfgMU.User{1})

%%
% The number of users per RU, and mapping of users to RUs is determined by
% the allocation index. The |UserNumbers| property of an RU object
% indicates which users (elements of the |cfgMU.User| cell array) are
% transmitted on that RU. Similarly, the |RUNumber| property of each User
% object, indicates which RU (element of the |cfgMU.RU| cell array) is used
% to transmit the user:
%
% <<../heRUUserLink.png>>
%
% This allows the properties of an RU associated with a User to be accessed
% easily:

ruNum = cfgMU.User{2}.RUNumber; % Get the RU number associated with user 2
disp(cfgMU.RU{ruNum}.SpatialMapping); % Display the spatial mapping

%%
% When an RU serves multiple users, in a MU-MIMO configuration, the
% |UserNumbers| property can index multiple users:
%
% <<../heRUUserLinkMU.png>>
%
% Once the |cfgMU| object is created, transmission parameters can be set as
% demonstrated below.

% Configure RU 1 and user 1
cfgMU.RU{1}.SpatialMapping = 'Direct';
cfgMU.User{1}.APEPLength = 1e3;
cfgMU.User{1}.MCS = 2;
cfgMU.User{1}.NumSpaceTimeStreams = 4;
cfgMU.User{1}.ChannelCoding = 'LDPC';

% Configure RU 2 and user 2
cfgMU.RU{2}.SpatialMapping = 'Fourier';
cfgMU.User{2}.APEPLength = 500;
cfgMU.User{2}.MCS = 3;
cfgMU.User{2}.NumSpaceTimeStreams = 2;
cfgMU.User{2}.ChannelCoding = 'LDPC';

% Configure RU 3 and user 3
cfgMU.RU{3}.SpatialMapping = 'Fourier';
cfgMU.User{3}.APEPLength = 100;
cfgMU.User{3}.MCS = 4;
cfgMU.User{3}.DCM = true;
cfgMU.User{3}.NumSpaceTimeStreams = 1;
cfgMU.User{3}.ChannelCoding = 'BCC';

%%
% Some transmission parameters are common for all users in the HE-MU
% transmission.

% Configure common parameters for all users
cfgMU.NumTransmitAntennas = 4;
cfgMU.SIGBMCS = 2;

%%
% To generate the HE-MU waveform, we first create a random PSDU for each
% user. A cell array is used to store the PSDU for each user as the PSDU
% lengths differ. The |getPSDULength()| method returns a vector with the
% required PSDU per user given the configuration. The waveform generator is
% then used to create a packet.

psduLength = getPSDULength(cfgMU);
psdu = cell(1,allocInfo.NumUsers);
for i = 1:allocInfo.NumUsers
    psdu{i} = randi([0 1],psduLength(i)*8,1,'int8'); % Generate random PSDU
end

% Create MU packet
txMUWaveform = wlanWaveformGenerator(psdu,cfgMU);

%%
% To configure an OFDMA transmission with a channel bandwidth greater than
% 20 MHz, an allocation index must be provided for each 20 MHz subchannel.
% For example, to configure an 80 MHz OFDMA transmission, four allocation
% indices are required. In this example four 242-tone RUs are configured.
% The allocation index |192| specifies one 242-tone RU with a single user
% in a 20 MHz subchannel, therefore the allocation indices |[192 192 192
% 192]| are used to create four of these RUs, over 80 MHz:

% Display 192 allocation index properties in the table (the 193rd row)
disp('Allocation #192 table entry:')
disp(allocationTable(193,:))

% Create 80 MHz MU configuration, with four 242-tone RUs
cfgMU80MHz = wlanHEMUConfig([192 192 192 192]);

%%
% When multiple 20 MHz subchannels are specified, the |ChannelBandwidth|
% property is set to the appropriate value. For this configuration it is
% set to |'CBW80'| as four 20 MHz subchannels are specified. This is also
% visible in the allocation plot.

disp('Channel bandwidth for HE-MU allocation:')
disp(cfgMU80MHz.ChannelBandwidth)
showAllocation(cfgMU80MHz,axAlloc)

%% HE Multi User Format - MU-MIMO
% An HE-MU packet can also transmit an RU to multiple users using MU-MIMO.
% For a full band MU-MIMO allocation, the allocation indices between 192
% and 199 configure a full-band 20 MHz allocation (242-tone RU). The index
% within this range determines how many users are configured. The
% allocation details can be viewed in the allocation table. Note the
% |NumUsers| column in the table grows with index but the |NumRUs| is
% always 1. The allocation table can also be viewed in the <#38 Appendix>.

disp('Allocation #192-199 table entries:')
disp(allocationTable(193:200,:)) % Indices 192-199 (rows 193 to 200)

%%
% The allocation index |193| transmits a 20 MHz 242-tone RU to two users.
% In this example, we will create a transmission with a random spatial
% mapping matrix which maps a single space-time stream for each user, onto
% two transmit antennas.

% Configure 2 users in a 20 MHz channel
cfgMUMIMO = wlanHEMUConfig(193);

% Set the transmission properties of each user
cfgMUMIMO.User{1}.APEPLength = 100; % Bytes
cfgMUMIMO.User{1}.MCS = 2;
cfgMUMIMO.User{1}.ChannelCoding = 'LDPC';
cfgMUMIMO.User{1}.NumSpaceTimeStreams = 1;

cfgMUMIMO.User{2}.APEPLength = 1000; % Bytes
cfgMUMIMO.User{2}.MCS = 6;
cfgMUMIMO.User{2}.ChannelCoding = 'LDPC';
cfgMUMIMO.User{2}.NumSpaceTimeStreams = 1;

% Get the number of occupied subcarriers in the RU
ruIndex = 1; % Get the info for the first (and only) RU
ofdmInfo = wlanHEOFDMInfo('HE-Data',cfgMUMIMO,ruIndex);
numST = ofdmInfo.NumTones; % Number of occupied subcarriers

% Set the number of transmit antennas and generate a random spatial mapping
% matrix
numTx = 2;
allocInfo = ruInfo(cfgMUMIMO);
numSTS = allocInfo.NumSpaceTimeStreamsPerRU(ruIndex);
cfgMUMIMO.NumTransmitAntennas = numTx;
cfgMUMIMO.RU{ruIndex}.SpatialMapping = 'Custom';
cfgMUMIMO.RU{ruIndex}.SpatialMappingMatrix = rand(numST,numSTS,numTx);

% Create packet with a repeated bit sequence as the PSDU
txMUMIMOWaveform = wlanWaveformGenerator([1 0 1 0],cfgMUMIMO);

%%
% A full band MU-MIMO transmission with a channel bandwidth greater than 20
% MHz is created by providing a single RU allocation index within the range
% 200-223 when creating the <matlab:doc('wlanHEMUConfig') wlanHEMUConfig>
% object. For these allocations HE-SIG-B compression is used.
%
% The allocation indices between 200 and 207 configure a full-band MU-MIMO
% 40 MHz allocation (484-tone RU). The index within this range determines
% how many users are configured. The allocation details can be viewed in
% the allocation table. Note the |NumUsers| column in the table grows with
% index but the |NumRUs| is always 1.

disp('Allocation #200-207 table entries:')
disp(allocationTable(201:208,:)) % Indices 200-207 (rows 201 to 208)

%%
% Similarly, the allocation indices between 208 and 215 configure a
% full-band MU-MIMO 80 MHz allocation (996-tone RU), and the allocation
% indices between 216 and 223 configure a full-band MU-MIMO 160 MHz
% allocation (2x996-tone RU).
%
% As an example, the allocation index |203| specifies a 484-tone RU with 4
% users:

cfg484MU = wlanHEMUConfig(203);
showAllocation(cfg484MU,axAlloc)

%% HE Multi User Format - OFDMA with RU Sizes Greater Than 242 Subcarriers
% For an HE-MU transmission with a channel bandwidth greater than 20 MHz,
% two HE-SIG-B content channels are used to signal user configurations.
% These content channels are duplicated over each 40 MHz subchannel for
% larger channel bandwidths, as described in Section 28.3.10.8.3 of [ <#39
% 1> ]. When an RU size greater than 242 is specified as part of an OFDMA
% system, the users assigned to the RU can be signaled on either of the two
% HE-SIG-B content channels. The allocation index provided when creating an
% <matlab:doc('wlanHEMUConfig') wlanHEMUConfig> object controls which
% content channel each user is signaled on. The allocation table in the
% <#38 Appendix> shows the relevant allocation indices.
%
% As an example, consider the following 80 MHz configuration which serves 7
% users:
%
% * One 484-tone RU (RU #1) with four users (users #1-4)
% * One 242-tone RU (RU #2) with one user (user #5)
% * Two 106-tone RUs (RU #3 and #4), each with one user (users #6 and #7)
%
% To configure an 80 MHz OFDMA transmission, four allocation indices are
% required, one for each 20 MHz subchannel. To configure the above scenario
% the allocation indices below are used:
%
% |[X Y 192 96]|
%
% * |X| and |Y| configure the 484-tone RU, with users #1-4. The possible
% values of |X| and |Y| are discussed below.
% * |192| configures a 242-tone RU with one user, user #5.
% * |96| signals two 106-tone RUs, each with one user, users #6 and #7.
%
% The selection of |X| and |Y| configures the appropriate number of users
% in the 242-tone RU, and determines which HE-SIG-B content channel is used
% to signal the users. A 484-tone RU spans two 20 MHz subchannels,
% therefore two allocation indices are required. All seven users from the
% four RUs will be signaled on the HE-SIG-B content channels, but for now
% we will only consider the signaling of users on the 484-tone RU. For the
% 484-tone RU, the four users can be signaled on the two HE-SIG-B content
% channels in different combinations as shown in Table 1.
%
% <<../heMUParameterizationTable1.png>>
%
% An allocation index within the range 200-207 specifies 1-8 users on a
% 484-tone RU. To signal no users on a content channel, the allocation
% index |114| or |115| can be used, for a 448-tone or 996-tone RU.
% Therefore, the combinations in Table 1 can be defined using two
% allocation indices as shown in Table 2. The two allocation indices in
% each row of Table 2 are |X| and |Y|.
%
% <<../heMUParameterizationTable2.png>>
%
% Therefore, to configure 'Combination E' the following 80 MHz allocation
% indices are used:
%
% |[114 203 192 96]|
%
% * |114| and |203| configure the 484-tone RU, with users #1-4.
% * |192| configures a 242-tone RU with one user, user #5.
% * |96| signals two 106-tone RUs, each with one user, users #6 and #7.

cfg484OFDMA = wlanHEMUConfig([114 203 192 96]);
showAllocation(cfg484OFDMA,axAlloc);

%%
% The HE-SIG-B allocation signaling can be viewed with the function
% <matlab:help('hePlotHESIGBAllocationMapping')
% hePlotHESIGBAllocationMapping>. This shows the user fields signaled on
% each HE-SIG-B content channel, and which RU and user in the
% <matlab:doc('wlanHEMUConfig') wlanHEMUConfig> object, each user field
% signals. In this case we can see the users on RU #1, 3 and 4 are all
% signaled on content channel 2, and the user of RU #2 is signaled on
% content channel 1. The second content channel signals six users, while
% the first content channel only signals one user. Therefore, the first
% content channel will be padded up to the length of the second for
% transmission. In the diagram, the RU allocation information is provided
% in the form index-size, e.g. RU8-106 is the 8th 106-tone RU.

figure;
hePlotHESIGBAllocationMapping(cfg484OFDMA);
axSIGB = gca; % Get axis handle for subsequent plotting

%%
% To balance the user field signaling in HE-SIG-B, we can use 'Combination
% B' in Table 2 when creating the allocation index for the 484-tone RU.
% This results in two users being signaled on each content channel of
% HE-SIG-B, creating a better balance of user fields, and potentially fewer
% HE-SIG-B symbols in the transmission.

cfg484OFDMABalanced = wlanHEMUConfig([201 201 96 192]);
hePlotHESIGBAllocationMapping(cfg484OFDMABalanced,axSIGB);

%% HE Multi User Format - Central 26-Tone RU
% In an 80 MHz transmission, when a full band RU is not used, the central
% 26-tone RU can be optionally active. The central 26-tone RU is enabled
% using a name-value pair when creating the <matlab:doc('wlanHEMUConfig')
% wlanHEMUConfig> object.

% Create a configuration with no central 26-tone RU
cfgNoCentral = wlanHEMUConfig([192 192 192 192],'LowerCenter26ToneRU',false);
showAllocation(cfgNoCentral,axAlloc);

% Create a configuration with a central 26-tone RU
cfgCentral = wlanHEMUConfig([192 192 192 192],'LowerCenter26ToneRU',true);
showAllocation(cfgCentral,axAlloc);

%%
% Similarly, for a 160 MHz transmission, the central 26-tone RU in each 80
% MHz segment can be optionally used. Each central 26-tone RU can be
% enabled using name-value pairs when creating the
% <matlab:doc('wlanHEMUConfig') wlanHEMUConfig> object. In this example
% only the upper central 26-tone RU is created. Four 242-tone RUs, each
% with one user are specified with the allocation index |[200 114 114 200
% 200 114 114 200]|.

cfgCentral160MHz = wlanHEMUConfig([200 114 114 200 200 114 114 200],'UpperCenter26ToneRU',true);
disp(cfgCentral160MHz)

%% HE Multi User Format - Preamble Puncturing
% In an 80 MHz or 160 MHz transmission, 20 MHz subchannels can be punctured
% to allow a legacy system to operate in the punctured channel. This method
% is also described as channel bonding. To null a 20 MHz subchannel the 20
% MHz subchannel allocation index |113| can be used. The punctured 20 MHz
% subchannel can be viewed with the |showAllocation| method.

% Null second lowest 20 MHz subchannel in a 160 MHz configuration
cfgNull = wlanHEMUConfig([192 113 114 200 208 115 115 115]);

% Plot the allocation
showAllocation(cfgNull,axAlloc);

%%
% The punctured 20 MHz can also be viewed with the generated waveform and
% the spectrum analyzer.

% Set the transmission properties of each user in all RUs
cfgNull.User{1}.APEPLength = 100;
cfgNull.User{1}.MCS = 2;
cfgNull.User{1}.ChannelCoding = 'LDPC';
cfgNull.User{1}.NumSpaceTimeStreams = 1;

cfgNull.User{2}.APEPLength = 1000;
cfgNull.User{2}.MCS = 6;
cfgNull.User{2}.ChannelCoding = 'LDPC';
cfgNull.User{2}.NumSpaceTimeStreams = 1;

cfgNull.User{3}.APEPLength = 100;
cfgNull.User{3}.MCS = 1;
cfgNull.User{3}.ChannelCoding = 'LDPC';
cfgNull.User{3}.NumSpaceTimeStreams = 1;

% Create packet
txNullWaveform = wlanWaveformGenerator([1 0 1 0],cfgNull);

spectrumAnalyzer = dsp.SpectrumAnalyzer;
spectrumAnalyzer.SampleRate = wlanSampleRate(cfgNull);
spectrumAnalyzer.Title = '160 MHz HE-MU Transmission with Punctured 20 MHz Channel';
spectrumAnalyzer(txNullWaveform);

%% Trigger-Based MU Format
% The HE trigger-based (TB) format allows for OFDMA or MU-MIMO transmission
% in the uplink. Each station (STA) transmits an HE-TB packet
% simultaneously, when triggered by the access point (AP). An HE-TB
% transmission is controlled entirely by the AP. All the parameters
% required for the transmission are provided in a trigger frame to all STAs
% participating in the TB transmission. In this example a TB transmission
% for three users in an OFDMA/MU-MIMO system is configured; three STAs will
% transmit simultaneously to an AP.
%
% The 20 MHz allocation |97| is used which corresponds to two RUs, one
% of which serves two users in MU-MIMO.

disp('Allocation #97 table entry:')
disp(allocationTable(98,:)) % Index 97 (row 98)

%%
% The allocation information is obtained by creating a MU configuration
% with <matlab:doc('wlanHEMUConfig') wlanHEMUConfig>.

% Generate an OFDMA allocation
cfgMU = wlanHEMUConfig(97);
allocationInfo = ruInfo(cfgMU);

%%
% In an HE-TB transmission several parameters are the same for all users in
% the transmission. Some of these are specified below:

% These parameters are the same for all users in the OFDMA system
channelBandwidth = cfgMU.ChannelBandwidth; % Bandwidth of OFDMA system
numSymbols = 20;          % Number of HE data field symbols
preFECPaddingFactor = 2;  % Pre-FEC padding factor
ldpcExtraSymbol = false;  % LDPC extra symbol
numHELTFSymbols = 2;      % Number of HE-LTF symbols

%%
% A TB transmission for a single user within the system is configured with
% an |heTBConfig| object. In this example, a cell array of three objects is
% created to describe the transmission of the three users.

% Create a trigger configuration for each user
numUsers = allocationInfo.NumUsers;
cfgTriggerUser = repmat({heTBConfig},1,numUsers);

%%
% The non-default system-wide properties are set for each user.

for userIdx = 1:numUsers
    cfgTriggerUser{userIdx}.ChannelBandwidth = channelBandwidth;
    cfgTriggerUser{userIdx}.NumDataSymbols = numSymbols;
    cfgTriggerUser{userIdx}.PreFECPaddingFactor = preFECPaddingFactor;
    cfgTriggerUser{userIdx}.LDPCExtraSymbol = ldpcExtraSymbol;
    cfgTriggerUser{userIdx}.NumHELTFSymbols = numHELTFSymbols;
end

%%
% Next the per-user properties are set. When multiple users are
% transmitting in the same RU, in a MU-MIMO configuration, each user must
% transmit on different space-time stream indices. The properties
% |StartingSpaceTimeStream| and |NumSpaceTimeStreamSteams| must be set for
% each user to make sure different space-time streams are used. In this
% example user 1 and 2 are in a MU-MIMO configuration, therefore
% |StartingSpaceTimeStream| for user two is set to |2|, as user one is
% configured to transmit 1 space-time stream with |StartingSpaceTimeStream
% = 1|.

% These parameters are for the first user - RU#1 MU-MIMO user 1
cfgTriggerUser{1}.RUSize = allocationInfo.RUSizes(1);
cfgTriggerUser{1}.RUIndex = allocationInfo.RUIndices(1);
cfgTriggerUser{1}.MCS = 4;                     % Modulation and coding scheme
cfgTriggerUser{1}.NumSpaceTimeStreams = 1;     % Number of space-time streams
cfgTriggerUser{1}.NumTransmitAntennas = 1;     % Number of transmit antennas
cfgTriggerUser{1}.StartingSpaceTimeStream = 1; % The starting index of the space-time streams
cfgTriggerUser{1}.ChannelCoding = 'LDPC';      % Channel coding

% These parameters are for the second user - RU#1 MU-MIMO user 2
cfgTriggerUser{2}.RUSize = allocationInfo.RUSizes(1);
cfgTriggerUser{2}.RUIndex = allocationInfo.RUIndices(1);
cfgTriggerUser{2}.MCS = 3;                     % Modulation and coding scheme
cfgTriggerUser{2}.NumSpaceTimeStreams = 1;     % Number of space-time streams
cfgTriggerUser{2}.StartingSpaceTimeStream = 2; % The starting index of the space-time streams
cfgTriggerUser{2}.NumTransmitAntennas = 1;     % Number of transmit antennas
cfgTriggerUser{2}.ChannelCoding = 'LDPC';      % Channel coding

% These parameters are for the third user - RU#2
cfgTriggerUser{3}.RUSize = allocationInfo.RUSizes(2);
cfgTriggerUser{3}.RUIndex = allocationInfo.RUIndices(2);
cfgTriggerUser{3}.MCS = 4;                     % Modulation and coding scheme
cfgTriggerUser{3}.NumSpaceTimeStreams = 2;     % Number of space-time streams
cfgTriggerUser{3}.StartingSpaceTimeStream = 1; % The starting index of the space-time streams
cfgTriggerUser{3}.NumTransmitAntennas = 2;     % Number of transmit antennas
cfgTriggerUser{3}.ChannelCoding = 'BCC';       % Channel coding

%%
% A packet containing random data is now transmitted by each user with
% |heTBWaveformGenerator|. The waveform transmitted by each user is stored
% for analysis.

trigInd = heTBFieldIndices(cfgTriggerUser{1}); % Get the indices of each field
txTrigStore = zeros(trigInd.HEData(2),numUsers);
for userIdx = 1:numUsers
    % Generate waveform for a user
    cfgTrigger = cfgTriggerUser{userIdx};
    txPSDU = randi([0 1],getPSDULength(cfgTrigger)*8,1);
    txTrig = heTBWaveformGenerator(txPSDU,cfgTrigger);

    % Store the transmitted STA waveform for analysis
    txTrigStore(:,userIdx) = sum(txTrig,2);
end

%%
% The spectrum of the transmitted waveform from each STA shows the
% different portions of the spectrum used, and the overlap in the MU-MIMO
% RU.

spectrumAnalyzer = dsp.SpectrumAnalyzer;
spectrumAnalyzer.SampleRate = heTBSampleRate(cfgTriggerUser{1});
spectrumAnalyzer.ChannelNames = {'RU#1 User 1','RU#1 User 2','RU#2'};
spectrumAnalyzer.ShowLegend = true;
spectrumAnalyzer.Title = 'Transmitted HE-TB Waveform per User';
spectrumAnalyzer(txTrigStore);

%% Appendix
% The RU allocation table for allocations <= 20 MHz is shown below, with
% annotated descriptions.
%
% <<../heParameterizationAllocationTable.png>>
%
% The RU allocation and HE-SIG-B user signaling for allocations > 20 MHz
% is shown in the table below, with annotated descriptions.
%
% <<../heParameterizationGT242AllocationTable.png>>
%
% This example uses the following helper objects and functions:
%
% * <matlab:edit('hePlotHESIGBAllocationMapping') hePlotHESIGBAllocationMapping.m>
% * <matlab:edit('heRUAllocationTable.m') heRUAllocationTable.m>
% * <matlab:edit('heTBConfig.m') heTBConfig.m>
% * <matlab:edit('heTBFieldIndices.m') heTBFieldIndices.m>
% * <matlab:edit('heTBSampleRate.m') heTBSampleRate.m>
% * <matlab:edit('heTBWaveformGenerator.m') heTBWaveformGenerator.m>

%% Selected Bibliography
% # IEEE P802.11ax(TM)/D3.1 Draft Standard for Information technology
% - Telecommunications and information exchange between systems - Local and
% metropolitan area networks - Specific requirements - Part 11: Wireless
% LAN Medium Access Control (MAC) and Physical Layer (PHY) Specifications -
% Amendment 6: Enhancements for High Efficiency WLAN.