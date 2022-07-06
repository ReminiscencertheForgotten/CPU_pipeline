fp = open(r'inst.txt', 'r')
line_number = len(fp.readlines())
fp.close()
fp = open(r'inst.txt', 'a')
while line_number < 512:
    fp.write('00000000\n')
    line_number += 1
fp.close()
