ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.14.2
docker tag hyperledger/composer-playground:0.14.2 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ��Y �=�r�Hv��d3A�IJ��&��;cil� 	�����*Z"%�$K�W��$DM�B�Rq+��U���F�!���@^�� ��E�$zf�� ��ӧo�֍Ӈ*V���)����uث��1T��?yD"�����B�y"�Ĩ$JQ�b$$O��@�/ǲ�	�ۄ͚�����:ȴ4l��g!��)���8 <�0w�g�Ͱ�f �܀-�3|�j-X'e�^�:R�����CmcӶ\� ���ma[ء^�2dt4-d���a�谔*�'��lf��= �z���@S���n�|���l�B��˛�$���吱��L4�!SV[��/���:X	)&�i��a�RJ%U#��\�v�.0�D�]ܹ�f>�Ϧ��0�b�I;2qM���	6�ik�5X55e��Ud)�ֶ���FҬ2�~a�T�Z눋��w���M�h��q�?dh�x*YE���v��]f���aSE&a��k<F��S�]��me'�(��%l�uDG����e�П�F��lE[LԠhA����&i�C�.�JG�p��b�p��7l�MƯ@?&t��/-�Ψ?���#�F��&�� ˮƖ�Rf�t�i�a��R}2��M����0]���Q�s���l2���tt�z�K���d�v�{���\�SQ�G�?�����A��h4<���0�����#��$��O@��{2�p�o��ۈ�Q�k���o5��[�����A����)'�����U���U�T���,�
��M��쟪�Tc���q��w^:��w>�x�����Uɧ���!q6�|����3��>]��*�bp-������0C��Pi�:�_X�x�6���4��O
�)�������n:�ޛ��6�c'b���a�t�h�md�+����Y�9�5l��Z�Mň�i٠�tg��6��i�l�A��D�fc�7<���5����XdCK�4�*��f�Q�떟��M)����3��W�ퟮ)ȰX�2�����(z�Dv��h�Ϗ5<�eU�JSi��oaݡjю|𦹍�V4vx=�;��h����>h*��p������G��c9�w�8@�|�FK"y��R��������V�_i�#�/���Gd�'��'�:���D����d|>X���u=����\����I�DAZ��U����=��5�`���n@45]�P��Z��H!�c�Q���a%����-�����*c!ж������;�M�ă�n�<��4�*@J~��GiC���vx ���a޹���'���4�xp�q8�zpn�E:�A�i�lF�j��>���p�����d��"Bb8c.
���Q�=�&�my��z�:���u�%�&��ڕ���<�̦�mpADf�U�<2��[�GU>�?�A��{lB���C�@��B�K�v�H��#"�
�f�J��*&{v�L����B��������t�ؠ�Д�̳?�s?Z���9���M6�YG ��9O�8�P� �A��#��'�qzM:�Q�M>g8ã����8��j"�|�z�8��ѝ��7+��<t��^9��©�@k����O���~(���'���?V��/f��h-��%�/J�������Հ�'%G�0�w�-�3���Ӯu�L���v3&��N�c������f�Kf����N��^�t^J�G�ݟ�nB^5�����������1���%�,��������l��8U,e�//�#��sz'�fǰ���8�Ӣ�aC��F���
�^T�tͧI(ҭ��瓏Hg�N�fKe�X>/gs��Jy~�'�f�]�M��R��C���+��1P��D�/��N��>�|΢�H��ށ�3��3xn"��nI�s9��; O\q�UE&~�>����@�u�,��N x�J���_�x*�;.��lAP�I.�#6C�+d�`��N΋軏5����k�o5����l��������e��i�/�������=�T���n� ����k���]��'���,�Z��f����t�6�ɿ�9�#��?W�ן�p��w^�Fp��+�ۮ�}����������B���_	L��M�]86�ܴl�L��@���{!�jAC��݁�P�Z{d�w],�~rL�������3���ϋO���|LDȖ����1�7�]�,���Y6jdDz���EF�������tp+�jS%�r��t�Vȴ���c�4u�@�Iو{f��Ϭ�?��3ު#�ۄ{��bO!�n�~k�E)XE`�2A<�Ιj��3�;%N�`�4�Ac�r����>A���T�>�	�����������D>R��B��x!"6������Q)�큫��� ����8�^{�a�'���_�w�V�ѹK�������P�U��m��>A��?,E��?��%���V��XƖVoؠ:���~�Ox=0���v�n+��y)�4�72-�R4���]	�W���?w�����B��)��جH3���瀌��e �ZM�]�kϣ�)�
�"��V�a��0xC�����Bt��R�i��-gm�]���ҌgK����ڽdFY#�~��-�M2�%��x�;�StLԑ�W`2���L^�6�R�̜1��t��Y�1&*���T"���{��Ta���S��J�3Ç���a/Jf�ե����)D�Ǒ��dލ-�j�P��[������6�~�/F����p��)1W=���em�^p�WG���ai�����k�����������������a����
UE����"*���jMR�c�H�J�(D������B��X8���p��o����_��	o������n��_�#��m|��5oO�}�q	lXش5������m,ب����j�/_M�����jD��߳\w�ƿl��7��������Dp���$�W�����S���Âq�"��c8^� �������Wޅ��?�p�����HX����'��0��m�X���7�_����_\{{���t����l��d!�7I_�F�t?����Ԧ����5oiuzΖe�GPDQ��*�h�Z��vHخm�PM���JL
��ȶ
%$	
��0V�Ơ$���	mH�WQ�5j�p|�L6�b9��&�r���7r�l"s�H�J�.w�q��-�y��8ο쩁x���F5�j�n�~���g٫!Ep��U�P��Y���\��8w�����z���*'��F5����7<I]�/��L)'��3-�yo(��sԯN�ۗ�������T&�;�J9go��۸uV
_T���^R�.N��
��L��^C���J7���Yᰜ�вV&��'�j�`u���q��Iu�W�R��8:�D<�_�-xr�QZ��i9u��ܑ_���J0�dSg�ӓ�|���^�j���0�n��pR��IX&sa�JaeҶ���Z�N�?#3�e⽏�RN���T&��>wS{����g{�2^3��R9w�:��[�t��"lG�dN��7�=�yrՋ��)ܗ��P-iZ8=������|)��r�Q1r&�z�zw��\��d��魚��n���^=)��\�sq����/d9����l���%��l�e�A'��c��x���>�[D�����HN�	�.wr2���`B�r.UId	��/D��T�c�|��mx����e4���qR��:	5P��K��n���T�Ʃ6Le��X�)�7�������R,�Q󕢼��`,��'g������l�4��H:fL�3[?�_�ܐC_@ňy�?0��&��"�e���������GS�|aE�d��~���:�o%0�'���8���)+}�岙=b��E6:����P�B]�݃��>�1�Y�<���c�$�E�̉�w�t)W���t��J�r��$�B%_l�*ͫ4LD_^K���_VQ�)'7+�B1��u��3Z=�81*;�� 
BE$+N� �WP�s�K<冖���>���r��a����?������f�������2�p��_��\	���J� �7��f7�=��?rax��J�P�S0�5S�d��or�'u'`��M��Z��>L��s�R���[�8]�50��q[��?h^ن�2䣮x`i�K!��6��,L����q>ݳ�=k����mLKjZ�߃����%������W�@�{&����s���Y�A��Y��_�~���<J���io}�YnMC��%x��p@��nҡY�x�IT��EL��ꂆv��-Ђ���'^�0��.�<d���CZ�a�Sz^�@���GpF- ��-�;`,���?t۔"_j#��b	!@_;�YU��.A��FG6c	��7�+���Ö��B��;�ȃ�ޚ�idۣ��'�ſu�Q���q�tx�c��ѯ4Ȗ�����h�I���W�%�w�l�cWc,D#i8+�a��蹆�1_��@��]z���K��2"�m�ʕF��G��^ ���	{�AZH�e������m��h���ŀ�
]���ٔ��YD�l/�@����~a��(�����J�?F'A�.ol2��-�j��j�7<��v8���<��"�z�'��M��������rWG�$�31c��������7���}~!/7m�^k 퓹�@�!����:C�<$M/I͡DD�k�0�զ��Az��h�=�m�W��1)�Z��=���91��P�W���;<�M�k����`*H�y�EV	��.U�9�����@O��wG��'�HE��M�vi���a��Q��e��d��2�)%:�M�Wk"7P��Tޭ%Pœ��a��۝b���H.i/�Lq����MVi�{���+b��]������9}��>i��&�tۥOEes��[�	�c"�C�Ȯ�ʐNM*�rl�NQ*��XD�����M0Ul7<z�Jw3Y��a�n�:�펎��*���&�-C2�
m����+X�5�#�#qNyB�w�v܌}�t�i��a�Hd�v;b�|�}�1K���'��_|4q�X,��c���<��Զ�(��Ή5���$�2��y���N-ВM����֑A,��g?b�����Q
	������w-��ci���i.HM?(�!T3ݨ/U~$v�˔�v�$΍�t�,���I�8�;q�*iZi@�A�f;$f�����A,X �X���#�㾫ruN�o�k���_��;�O��^��Q0��������7���ߞ��7?��\1������������}�G��#�7�^�����~��o�[��ń*�Y�
EC�"aR8$G��b-f(i�!<�P$�5�p��b��Q'�-Ec��~!�f�Q��_����r����I��_���:7s_�?z�?���a�w���`�|y{����~���������s����ޣ�|�|M(���0����?=D~�����-�C��b@� ZL�h��n��h���ұ�B꽲ɰ�)��w��\�P`���*��*\���U�iم�Ba7��k	��F`��NpSdwFZI��<��	�W��)���la?+x�!%��K:m#��"�UD�(��=4�3�l�:7�Es�u�b�L��]�3q�B�S���Av�"�3��7&�p��k��yfP	׫��L��u"fE�Lv`���^�D��x��j�_ p�ΰ�~_?旧�3�3�]4��\�4L�>�O���ev��bЉ\�P-���M��L$��~nΔd�LYɮ�m	�dA7�X�.�P��־�t"����t=�0	�m�&�,ڙ�&�gKz!g�0�w
��dh��������t>@i���Ԭ��F�L}�ow���M�"[��,�|'���P��3���u�Ǣ�<V3ejr����b���̴�5�U&)iV-��"�F�ٸI���џ��cE�B[�V��:��b��x%7�{��z��y��x��w��v��u��t��s��r��q��\^�̻ț�M�?I*�W2J�j��S;ܬ&���[�T6���b|��V;Ľ��΅���/�{�z�PH�o�z�{n�z�f�j ���7�f�v�q�O��^��+&#�ih����j�Q˭�B�%�Q��"�rS&tB��i���*O�e)�(����&81�#�M����ꟛ��HcD���t,�IH��eg�Z�еp*'ѽ���"2O��n�ܼP�d��,��ȔK�(��i�t�̚�a�ډ�2d��8ُ�t-�g��M�	�K�N+*Un�s�V��6+���v|0�R�.�.l��ůo~�������[ֿo���mp{˱������K��ƮW»!��^ܾ�|ks�ijk�$����Gn�}�:�P�{��tыǿ�;8���f���k^.*��@o���>��7�G��O��臎��'�����{��ϯe��%�di��y#:ˉ����"�E�5Jn��t�$�h��`钫���&߷̄-XX�$�CɅ��j,��J.�6V�_r!��*�\�]��)�kSv%p_��� �*�"�i9ʂgV�C`�1!�(�
�O�"S*N���q^I�
H�ʇ��S96����7�cu���i�E��ASi��i�aZ����� ���8]�Q��tΖ2Q��Z��DҬ�4�N���,����Ha�B�8���T&�HMn9P��t��<�W�#CJ��-	4_��Diԭ�|���O�5E�ɦh��h�Vkʢ��%���-�Z$ܯ�,���M���e��XFHGh�1��6�v���k�qc6�T�^:��xA+����/��֕L�r�3��4���AA�f2\4��;�nq����/\���w�f�@N,�k ��l�Տ��UL�Ɗ\H`�l�[d��"���g��������q��-���@�Gם�Y�_�߬j�B�z*�o!��в'�ZM�YG��<QO��4[i��ᰤd3�q���c��L��0�3��0��F�6W�>O�j��GY�*�ϳY��w�p�h�6�9�P�4m����c��ѝ�`.��N!�;��|�����H�{~j��V!��9_�ēiaKU��
��K���U��d���SվX��\���&��́t��ԼX-��b8�L%��xJ��n���b]���p��rM/�nd��<��"Y����
�aM�L<�d������W���$�(�yµ5�G0B҄�����L��|�2��혫L���w
���^�PJ�a�P��N��c��Jyɓ�Zu��&\돹�N��Dt�(���-��1.it�TϢ$cd�,��ˣJ7Җ��LE���h��*��(;J�����c�p>\�����Y�gh�@�b�b'H_
)qC�z
�!��e�N8M��)Nʕ*��Z-6�ӳ�R�G�ck�ɨeTb�Ҽ�M�A�jn�X�Cٰ��V5VʱZ����<�4��K5�-�|�K���7ݼB�g7^�Lhe2_��g��бE��nLT��X����藑����P���b��B��G�����F2Zݒ�T��>B<������[�;0�h;J
�xy�Xyv��:�aT$M�mw�qMoWz����c�AJ�A�ZZ댬��`�#������y8V2$�@	~�N�������e���в<Qt]�d��}�J��.܋�ˬ!����]�-��<�1���+��aTh��C8����#��/�F���ף�_O���n+������r�CFS	*���Z��wx���dX����D(t;r�Cj�( �7�@�/z\Έ�|�����ؤ�����tq�� }�;'�O�7�����2������A8���N{���Ϭ�E�?�nWyE�^��ӫ�V1';:q��]/��Ԏ����X}YD]�!A'���h\�#Am@���ߏ���� m� ���,��(�P���� ���]��� ��ivq��ΰ�yc��A�bNu �/�Źt�FP�*����.�>r�<��95\ �_���j[5�Z���p6i<	~��%>
:���.��9YA������`c����}ځ��U4^e8S'�!��+������Ƴ@t�H�V0�>����z����2����dՉ�m��Ɏ�1���34Ǳ��5�F;^evU'��KC�����P������C�Љm�S�d\x�EǓ�J �0?Q�-u,i'��ȪQ��+"�E���r�r년��+&~�l��&���S����L�Vw4�6$�G�Wk� ����T���%?K@�y~U�@2�:��ܱ~Q��m�t��K| D��M��i�� ��F]���,�xB���ЧX<	�C�k���8
lؼ�p�#��>�_����"�ˮ�]�k�9�� 
A�ْ��A�>�]l4���O��Ε���Ad���z9�ƶ�<A�~GQ8���p��q�Htp��޾�(cC=�T;�a��������c��}ܗ�}Ɇ�:M�-�,v�ޖ{�	O�m����S��s�a�W �':�c�OSRA����Em*��,��r$����A
��`|w}|=��D�� g@���ֱ�Q�yP���1�i���]XՎ���
���z��4wjsAȘ�5�i������YfaX�lϕ�|��&�<܏Lo��@�+UҬaɫ.�:�t%�&����cѠ��{����زѽ����/H��-�o�z��Ÿ۪�F�}�E�D��b_}k��u�.��o��	!q"x���)��_��d���갦ꐮa�`�~	j �Ǭ�+{�WQ6'r' ��'0��pd��&n[b'"O18�$�ň���_�sL#��#p����Д�������-F�up�����a�&}Gn�[�/\8n��ۏ*�|�s?���C~�kG���?�k.���n|�����6���OF����d(�������C����A 	�-�*�sÖ�0���5��̾��u�f�|�,N����P�h�;�shrG�W�pE�[�����Y��J��g	>s��W����� ��O���r���#�,�C$�$$�IFb�"�!%D�)��j)m\��qI"�!��!7��v����"�t��mAԞ�r�ca���9�|,��|�
~����>��<C�1C�=��M�]g_YܬJ<&5)Rj6�X8�EdI�	%�¤�$I�),JE��ԔA	)d�d4��#
.Q�bML�Iӎ�s����83�n(��z��x�ܒГ��Y'<ٙ}On[w�v�ߑ�
��c�B��Y�hQu��rE:s��%3\��<���sq6�$rY�e�\����van�o�/	��ʱ��Q�Yw��{r���K�3B)ϳ�|�cW�����0���Y<WU }o���dp:�����s5T��Ўjt�MHK�k�δ��������qaۤ�M��t�e�ᱝ&
�A�`�[ݜ!���$����Ô�I~+����9@�I>�<�s\q����x�����i��1��z֊p�e�|�ϊϦCu~��(�g�Τ	:����OX4~fQ䥧G��.�]0��hi�ol.~jM�Jb<�M�ɳ,'Vs�S��3�����v�]c�@r;��Ԯ=O��m���e���ʖDZ��,-�]��A�S��$<W��X���;An�T2�P���xz<y���3��-i�r�����c1�GD'�4uw����g��nb����|�v���b�����X������Σ6�C@�Ա[[;�.7�B��Xq@+"�!�X�\�XMl��Ё���@�o�u�����Ł����	�X��e��ͣ;ڸ���,�8��>�_�-}������H���o������#�|�74�%�&l�!�!�c�o!���A��%�
���M�OF�����/�^�Iྦྷ�+��%�/��������?��K:x�9x�9x�y�ho�^	�����`��%���S�d��
�ڑ��[�#�cr�"[�,�b�(�R�(m�Z!2jF�Q���
&�֙����^���·��C���$���&���?��qM�p���i�9���s4%4���\(_ו��2�$7���@��j��>���T}F�!��Z���j����z[*�FHZ��~�tRJ�{�N�8�j�x%�ŔYMR����؋c����/?�
��p����r��<��i����:���#�
��v����i_��l�}�+��� ��_�o�����A��#ݳ�H�����t:�����w��G����^�+ ��U\ :��?��A�߻�'�m�O��>ҫ%����(���}����a�ڒ�D�����������ػ��DѮ{ϯx�]�e.޵>&n��$�����?MbUw�;�T���W)+����}�9g?��ΟB-��`��?JA���B�_�������O�� ����?�V�:��v���C�o)x��7������)u���e��~��:!�-�\���,*���5!��Z��O�gv?��!ZG����u����g���Of��������'�4p��
�\f�P�ga���f����ϭ�4�T���sŖ�U�
�|��5��Nc�!��ҏ&�͏a{hӗo����{���O�G�>��~�e29��{�`�[w�F�.���>�$9����l�nɿ��ϻEse/��ԕ#m��8vE��gӻF��b�ҴP{�HTړ�oS�{��~ȷ7,L=���˝���%#�LcG����L�Z�?��W�迧Q� ���_[�Ղ���_����U6jQ�?�����R �O���O��Tm��@����@�_G0�_�����������+�S��e�V�������Dԡ���������u������u­c>��3WUch;�~��+��������ϝ�謉_�#o�����2y��'�[���P\i�����Z1ܥZ����.�8)�����=EP�Nb7�Θ������R�7ۛ!�뚜=���_����������wD��s���_��+	��6>r�㿷�o^~��P�J�x����X��.i|JI��Ηڔ�	:!�Ͷ��Q����u"��p暤 ���n�Prd�
'��KF�h�O������������+5����]����k�:�?������RP'�f��3
|����<��P��I���g}��	�f|��|��i�"8�CC��qԁ���C�_~e�V�uq��d�l5uɒ�=�
y�A�΢�M���_����͑Ώ�<?�(��U�,�LL��t�sv��i`�M2_o��v�e�K����s�^ڌ���?l�'�:���^�����ա���~]�JQ��?�ա��?�����{����U�_u����ï���![Un7㈉L��g4�r����d�p��O�a�n���#�<�A3f\���].ջm�(�sd���/�'�D�:�2B?&�=2�U.tf��e��9�g�`l�<��M�s(��ދz��q�+B�������_��0��_���`���`�����?��@-����?�W��Nq��=����Ȼ�a=az'	�c�4������|p��om�rQ[�9 yz�'� @��g�p��~{���C��\x� �8�rh�|���'�Z$|�.��4ZMA��J��Y��4l���7"}8�1ꄗ�C�]דv�)看z3vN�o֋��s$r��n�<�k�����g vK�5�R�Hn	���w��]�ӌ�A���#A�X��ﺡP��HaY}�'�~����ib���`sMh����r&J��R�""L�������dCT䑊��C�j���[�Bc:U;BOg��� 	=�nGd�-�=>!�ͤo�E��W�u�u��~���<:	:���VW���z/�A�a��G��+���]��/ʸ�o�������`��ԁ�q�A���KA)��~�EY�����O�P�> ���!������`��"���0��h��<%Y�	� �C�G]�u]�&��AY�	���A��,�L����b秡����_�?��W��:}�,�Ԧ��c�{�hċ'I�ɹ���kdbP����9��IɃ�i�BK6J�A�{l�Cd�&�~��ݤ���������6�yFͶq�7މ鴬]%�-��}/�p�������S
>���U?K�ߡ�����&0���@-�����a��$���n��!㽎 �����/W��*B���_��?h�e����4�e����k������f�7�ASh��	'�re���E%�����e\�#?3�}}����k+����<���S��N�� o�~��z��<��6JzGF��Su����4G�C�+t6��xĬ��lꪼ�r3�)�q'�%V7%ӂ��vH�܎ruaYBO��6r��J�Y��kۉ�w�s��A8d7�-su�M�f�+n��C���x�ꐮ{��ʎxM�E��L5hD���gMC�u�s���i0�B��fl�#�(�H�LJ����=I+�SWVr�c&2i����g��c��C��c٥������ߊP������
�����������\��A�����o����R ��0���0��������,�Z��������������ӗ�������$��e �!��!�������o�_����!��Ъ�'�1ʸ���I��KA�G���� �/e����-T��������
�?�CT�����{����Ԁ�!�B ��W��ԃ�_`��ԋ�!�l���?��@B�C)��������O����a��$�@��fH����k�Z�?u7��_j���R�P�?� !��@��?@��?@��_E��!*��_[�Ղ���_���Q6jQ�?� !��@��?@��?T[�?���X
j���8���� ����������_��/���/u��a��:��?���������)�B�a����@�-�s�Ov!�� ��������ī���P���v�2�7C}�%Pv�r��'=��H�/$A������.�2.�a��r.IR����z����4�E�S�?*�K�U����v�Rq��T�
m4w�ހaD(�佞�&q����8}~���$�����jI�_Uc��C^y~�;��a��T��E��F1"��*ixa����}6�ԙj�B�u�v����N����C����d�=�c��:�y���K��'U�^3�����ա���~]�JQ��?�ա��?�����{����U�_u����ï��>�Q�ƾo��FM�}�7��b���_���i�Sy��V�ܛs�M�߰��n��� ��E�C�*Qx�N-e۴�����|����v�դA���f������f1�˔��{Q������������}��;����a�����������?����@V�Z�ˇ���������?�����?���q,��91�ő"����_+����Y�]��$8���Ro�X"���#Ҟ�[���lH�%��I�3M��`$H�v+�,���z�ڽhL�Ì��0R�/�=������^D�dA���gZ;ɑ{m7�^^�k��ӥ�����rM��vB$�����_���@w�N3���>��c�b��B���E�I�0��N�jv�,��l�J�9y�����Ǽ��#b6P�n�8B֧�ə���h����ǂ2���zn�`A�\���I�v&T#<l�es�I)fk�����I�OvA�{}x�;~���28�K�g\��|���'.��_�P�a��O��.���Jt��ڢ�����O��_���8���I��2P�?�zB�G�P��c����#Q�������(���{����F����A�8��]B�������?Zo��?D�u�4��ώ�t�Q�^�
��Z;������q������K�7߿�.]M�n���j]^��kj	��ؒ��[B�8����u�!�ԙ�a�#_�FF�́�(u5^��Nn��T3~6�٣c�J��E�J1w�s�ToR¾���ʶ�ѼM�
�p������'�nѲOVޓ��No�����B4��_�?��~��7[���NS���� 
�ݛZ[�!�M��!6�6�u�͎A5!~��tI�c�r�#��K���>��&+`٥�t��`4���L�Ӏ?�r�S!���H���n�Bn����]{�&Ч�Q��ܔ���r̙}i՗_��Z�?�n���%���x���ž�H��f�����I��f(��8=��Ip3�`<ڧ|4�8�Q`���P���~����`�������f|���A�<��`7y���8�ݓG(e�sG_����ʟ�
��rU+0��^|���j�~��Ca$�e��c�{��_)(���_�Q��������h���-��W\�?������c��ba �Ϻ�'t0���?�*������@��SO���`C>��-���!?��]�?���D��׿�~7�y��g���B��:́�nCJaka = �G5�֘�_��7�4�5:pbu�Ӽ��B?K����|����d��F��vGW����w��������:�f����G�ٻ�d�+��,M[f2��tY�*�����Ix^&m���z=�P+�0�rҿ�(JyM#[/��G��Oռ�*E3C�a͹�	��*l8�Mo�,�d�W���ܝf���}����G�?��[
J��S.�~H�,�3ǯ?��|E1a8�<��\�e����]���8F]�X� ��Q���q��x�����|�J��ա�i��vN9q�4\��9�v���}�7N��w����e�U� �-��������~��c��2P�wQ{���W������_8᱖ �����!��:����1��������w�?�C�_
����������ƴ�T{mh�^Of{�,:̇���/��5A��?�^���*����Gi��o!
ȷ�@N$K&4iz��Y��g}�\S���=��r�ֹB>ں�u����+��忧����w�Ojb�������:uny�y�CO��*@E�}��u+���N��~��N:љtf�l&�OU�v�[���^k��J�w]�u%���uNj�G�3�u����;z*��]k4�t]�o���j�t��9>�V{f4�{�Y�b9m�U:�[r�劘��?ݶZ�jx���)4����c�������q��Y�R7V<�oMֳ�F�k���^[�?^l��4���Vْ�6/Ju�����Bhj��1)uLy62��x5������*&-%�h�Y�Z?�z��ʀ)�u�ZIuG��e��8���j��I�.����\��O������7��dB�����W���m�/��?�#K��@�����2��/B�w&@�'�B�'���?�o��?��@.�����<�?���#c��Bp9#��E��D�a�?�����oP�꿃����y�/�W	�Y|����3$��ِ��/�C�ό�F�/���G�	�������J�/��f*�O�Q_; ���^�i�"�����u!����\��+�P��Y������J����CB��l��P��?�.����+㿐��	(�?H
A���m��B��� �##�����\������� ������0��_��ԅ@���m��B�a�9����\�������L��P��?@����W�?��O&���Bǆ�Ā���_.���R��2!����ȅ���Ȁ�������%����"P�+�F^`�����o��˃����Ȉ\���e�z����Qfh���V�6���V�Ě&_2)�����Z��eL�L�E��؏�[ݺ?=y��"w��C�6���;=e��Ex�:}���`W��ؔ��V�7�r�,IO��j]��XK��]��N�;u�dE?�)�Z�ƶ�͗�
�dG{�ݔ=!��4]�ݢ�:肸�Bbfk�6C�VXK2�*C�	���b���q�cתG��<s�����]����h�+���g��P7x��C��?с����0��������<�?������?�>qQ�����?��5�I˻Z�C���Hb1�(�e��q˶�Ӷ���rgO���_�:Z���`�э����fCM�"vX"�h�.�j��oՋ�mXù��5vy���|�TǮ6�Wr`R��
=	��ג���㿈@��ڽ����"�_�������/����/����؀Ʌ��r�_���f��G�����k��(����i=�0r�������M����+bM�ɔ��į�@q��`�r�M Alz�q�%I�ݟE�ݢ��ƚ>��uwR�K"}&V<.l����ة����$�M�Aj=z�\ks��u�]�6A��6�zE�6�l����ӯ��ya�h������d�]��]��OE�;���{Ex��$%N�� ;��YU+�c���{i�a/l>%��j�S(�tj9�����lԚ{�Lkl�,��fS�
��A����*aJ�t,�a�u�]��,�=btywุmȤ֮4����m������X��������v�`��������?�J�Y���,ȅ��W�x��,�L��^���}z@�A�Q�?M^��,ς�gR�O��P7�����\��+�?0��	����"�����G��̕���̈́<�?T�̞���{�?����=P��?B���%�ue��L@n��
�H�����\�?������?,���\���e�/������S���}��P�Ҿ=�#���*ߛps˸�����q�������ib��rW���a&�#M��^��;i������s��������nщ���x�ju~�I�Z�����be�Ì��yyC��Rѧ���!;3��08A���rf����i�������(M���h��s�/v%�Wӫ��#
��CK.H��G��m�>+�Z�[�e�:	�zޯ�L��3�uj�n6#���YMڒ��IV'��f5�������>v+E,D�\0k�0ۻce�2��4�}"8*�bu;���`�������n�[��۶�r��0���<���KȔ\��W�Q0��	P��A�/�����g`����ϋ��n����۶�r��,	������=` �Ʌ�������_����/�?�۱ר/"a�ri���As2����k����c�~�h�MomlF��4�����~��Pڇ�Zy�����E��T4��xOUg=��o*ڴEo�:_�!�)��+Q��>{�fq� h�v������Ʋ��#�s �4	��� `i��� �b!�	�=n��r���"�+�r�0e�U����taQ�{��'�zWRD6,oZr��#�rXa�)��A,�6u�+�ք�b}���n�&�ue����	���O���n����۶���E�J��"��G��2�Z��,N3�rI3�ER�-��9F�Xڢi�T6YʰH�'-�5L���r����1|���g&�m�O��φ��瀟�}�qK��t��'l$���Ҩ��'�^[�V5s���GoB��]0�@����OD��W�5&�X%^�vQ�Z��\�N%�.,OÎ9�z����,�T-+��>v�e7�����%�?��D��?]
u�8y����CG.����\��L�@�Mq��A���CǏ����n=^,kzGVEbNbb�h��r����֢�S�c'�n��?�/��p��}߯0���ˬ	)�c�c�:b'dq��uz@̏-��+>�jFmY7��zDg��q�Ckrp��ג���"������ y�oh� 0Br��_Ȁ�/����/������P�����<�,[�߲�Ʃ�gK������scw߱�@.��pK�!�y��)�G�, {^�e@ae�;m]墭�u���Պ�V���i��Z��Q�E%�S[Ec9+�ё���`���j�<�N���0�P��TiVhm��z)��ӗf��y�&��'>^�҈���օ8e�;��qS�:_ ��0`R��?a~�$��PWKUE҉ٶ�bN��w��1���(%g�)��Y�&��p�/�R��m��^ľ*(�T$�Օ��Ժ��eC�G��]�KN���qmώ-k`y�b��#��`��a�������Bo�gvw>�2=�8-�9����ő����>:�������Lb�}��4�������6]<�gZd�wO����/;����I��{A����H����#��w��_tHw���M\z�s�gSAN>&tB���E�.מ���?�_w�y���n��#J�u����LN�鏃�˃�?&w,��Z��ϛ�����y��>%Q�q�}��������q_��4����������q	]�7�zp"�sq�	�7�������F��^�O�Fs��=�~g��T��4���c䤯v��	=���?;W�$r��Ozd9�t<Z���39��	�����U�އw���s<��lx|����B������������;�����;����UrT��-�$��ݧ�;���|��H* �m��u�?��>���:y[�����|�n�^}�%�jy^?�f�6����	�<���Jvs\CK�Y��x�_�s]ǵ�u"o�������;�R���7�8P���p���k-H?��mt3��4���k����k��skrvg�=�O�y���L�M3 ���^:��~�7·���+���I�L�kaN��0#�X|n<�g�&��ɪ����)%-��"���Ɠڽ��N�����w�v��ȏ���I�	�0��څ_R�ûW5�2=�;��K����������>
                           ���d��[ � 