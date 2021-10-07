import argparse
from sys import stdout, stderr, stdin
import csv
from dataclasses import dataclass


@dataclass
class UserEntry:
    timestamp: str
    article_id: str
    wiki_id: str
    
    def __lt__(self, other):
        return self.timestamp < other.timestamp

    def __gt__(self, other):
        return self.timestamp > other.timestamp
    
    def __le__(self, other):
        return self.timestamp < other.timestamp or self.timestamp == other.timestamp
        
    def __ge__(self, other):
        return self.timestamp > other.timestamp or self.timestamp == other.timestamp

    def same_article(self, other):
        return self.article_id == other.article_id

    def same_wiki(self, other):
        return self.wiki_id == other.wiki_id



@dataclass
class VisitEntry:
    first: UserEntry
    last: UserEntry = None

    def _is_before(self, timestamp):
        return self.first.timestamp < timestamp

    def _is_after(self, timestamp):
        return self.last.timestamp < timestamp

    def _update(self, other):
        if self.first.timestamp == other.timestamp:
            return
        elif self.first > other:
            if self.last is None:
                self.last = self.first

            self.first = other
                
        elif self.last is None or self.last < other:
            self.last = other
        
    def update(self, timestamp: str, article_id: str, wiki_id: str):
        return self._update(UserEntry(timestamp, article_id, wiki_id))
    
    def is_single(self):
        return self.last is None

    def same_article(self):
        return self.first.same_article(self.last)
    
    def same_wiki(self):
        return self.first.same_wiki(self.last)


        

def get_args():
    parser = argparse.ArgumentParser(description='Do the homework')
    parser.add_argument('input', nargs='?', type=str, default='-',
        help='input file name or `-` for stdin')
    parser.add_argument('--output', '-o', type=str, default='-', 
                        help='output file or `-` for stdout')
    parser.add_argument('--delimiter', '-d', type=str, default='|', 
                        help='Input file delimiter')

    return parser.parse_args()


def get_reader(args):
    if args.input == '-':
        csvfile = stdin.read().splitlines()
    else:
        csvfile = open(args.input, 'r')

    return csv.reader(csvfile, delimiter=args.delimiter)


def get_writer(args):
    if args.output == '-':
        return csv.writer(stdout, delimiter=',', lineterminator='\n')
    else:
        return csv.writer(open(args.output, 'w', newline=''), delimiter=',')


def generate_visits(reader):
    visits = {}

    counter = 0
    missing = 0
    
    for line in reader:
        counter += 1
        if len(line) != 5:
            raise ValueError(f'Invalid number of fields in line {counter}: {line}')
        
        timestamp = line[2]
        user_id = line[3]

        metadata = {ele[:ele.index('=')]: ele[ele.index('=') + 1:]
                    for ele in line[-1][line[-1].index('?') + 1:].split('&')}
        
        if 'a' not in metadata or 'n' not in metadata:
            missing += 1
            continue

        article_id = metadata['a']
        wiki_id = metadata['n']
        
        if user_id not in visits:
            visits[user_id] = VisitEntry(UserEntry(timestamp, article_id, wiki_id))
        else:
            visits[user_id].update(timestamp, article_id, wiki_id)

    print(f"Processed lines: {counter}\n"
          f"Users registered: {len(visits)}\n"
          f"Missing fields: {missing}""", file=stderr)
    return visits


def main():
    args = get_args()

    reader = get_reader(args)
    visits = generate_visits(reader)

    writer = get_writer(args)

    writer.writerow(["User id","Is same article","Is same wiki"])

    multiple = 0

    for user_id, item in sorted(visits.items()):
        if item.is_single():
            continue
        multiple += 1

        writer.writerow([
            user_id,
            str(item.same_article()).upper(), 
            str(item.same_wiki()).upper()
        ])

    print(f'Multiple visits: {multiple}', file=stderr)


if __name__=='__main__':
    main()